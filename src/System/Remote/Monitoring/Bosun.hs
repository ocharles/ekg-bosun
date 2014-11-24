{-# LANGUAGE OverloadedStrings #-}

-- | This module lets you periodically flush metrics to a Bosun
-- backend. Example usage:
--
-- > main = do
-- >   store <- newStore
-- >   forkBosun defaultBosunOptions store
--
-- You probably want to include some of the predefined metrics defined
-- in the @ekg-core@ package, by calling e.g. the 'EKG.registerGcMetrics'
-- function defined in that package.
module System.Remote.Monitoring.Bosun
  ( BosunOptions(..)
  , defaultBosunOptions
  , forkBosun
  ) where

import Control.Applicative
import Control.Concurrent (ThreadId, forkFinally, myThreadId, threadDelay, throwTo)
import Control.Exception (try)
import Control.Lens hiding ((.=))
import Control.Monad (forever, when)
import Data.Aeson ((.=))
import Data.Int (Int64)
import Data.Monoid ((<>))
import System.IO.Unsafe (unsafePerformIO)
import System.Locale (defaultTimeLocale)

import qualified Data.Aeson as Aeson
import qualified Data.HashMap.Strict as HashMap
import qualified Data.Text as T
import qualified Data.Time as Time
import qualified Data.Time.Clock.POSIX as Time
import qualified Data.Vector as V
import qualified Network.BSD as Network
import qualified Network.HTTP.Client as HTTP
import qualified Network.Socket as Network
import qualified Network.URI as URI
import qualified Network.Wreq as Wreq
import qualified System.Metrics as EKG
import qualified System.Metrics.Distribution as Stats

--------------------------------------------------------------------------------
-- | Options to control how to connect to the Bosun server and how often to
-- flush metrics.
data BosunOptions = BosunOptions
  { -- | The route URL to Bosun.
    bosunRoot :: !URI.URI

    -- | The amount of time between sampling EKG metrics and pushing to Bosun.
  , flushInterval :: !Int

    -- | Tags to apply to all metrics.
  , tags :: !(HashMap.HashMap T.Text T.Text)
  } deriving (Eq, Show)


--------------------------------------------------------------------------------
firstHostName :: T.Text
firstHostName = unsafePerformIO (T.pack <$> Network.getHostName)
{-# NOINLINE firstHostName #-}


--------------------------------------------------------------------------------
-- | Defaults:
--
-- * @bosunRoot@ = @\"http://127.0.0.1:8070/\"@
--
-- * @tags@ = @[("host", hostname)]@
--
-- * @flushInterval@ = @10000@
defaultBosunOptions :: BosunOptions
defaultBosunOptions = BosunOptions
    { bosunRoot = URI.URI { URI.uriScheme = "http:"
                          , URI.uriAuthority = Just (URI.URIAuth { URI.uriUserInfo = ""
                                                                 , URI.uriRegName = "127.0.0.1"
                                                                 , URI.uriPort = ":8070"
                                                                 })
                          , URI.uriPath = "/"
                          , URI.uriQuery = ""
                          , URI.uriFragment = ""
                          }
    , tags          = HashMap.singleton "host" firstHostName
    , flushInterval = 10000
    }


--------------------------------------------------------------------------------
-- | Create a thread that periodically flushes the metrics in 'EKG.Store' to
-- Bosun.
forkBosun :: BosunOptions -> EKG.Store -> IO ThreadId
forkBosun opts store = do
  parent <- myThreadId
  forkFinally (do manager <- HTTP.newManager HTTP.defaultManagerSettings
                  let wreqOptions = Wreq.defaults & Wreq.manager .~ Right manager
                  loop store wreqOptions opts)
              (\r -> do case r of
                          Left e  -> throwTo parent e
                          Right _ -> return ())


--------------------------------------------------------------------------------
loop :: EKG.Store -> Wreq.Options -> BosunOptions -> IO ()
loop store httpOptions opts = forever $ do
  start <- time
  sample <- EKG.sampleAll store
  flushSample sample httpOptions opts
  end <- time
  threadDelay (flushInterval opts * 1000 - fromIntegral (end - start))

-- | Microseconds since epoch.
time :: IO Int64
time = (round . (* 1000000.0) . toDouble) `fmap` Time.getPOSIXTime
  where toDouble = realToFrac :: Real a => a -> Double

flushSample :: EKG.Sample -> Wreq.Options -> BosunOptions -> IO ()
flushSample sample httpOptions opts = do
  t <- Time.getCurrentTime
  V.mapM postOne (HashMap.foldlWithKey' (\ms k v -> pure (metrics k v t) <> ms) V.empty sample)
  return ()

  where
  postOne x =
    when (not (null x)) $ do
      res <- try (Wreq.postWith httpOptions
                                (URI.uriToString id ((bosunRoot opts) { URI.uriPath = "/api/put" }) "")
                                (Aeson.Array (V.fromList x)))
      case res of
        Left e -> do
          putStrLn $ "HTTP exception when posting ekg-bosun sample:"
          print (e :: HTTP.HttpException)

        Right _ ->
          return ()

  ametric n v t =
    Aeson.object [ "metric" .= n
                 , "value" .= v
                 , "timestamp" .= (Time.formatTime defaultTimeLocale "%s" t)
                 , "tags" .= Aeson.Object (Aeson.toJSON <$> tags opts)
                 ]

  metrics n v t =
    case v of
      EKG.Counter i -> [ ametric n i t ]
      EKG.Gauge i -> [ ametric n i t ]
      EKG.Distribution stats
        | Stats.count stats > 0
            -> [ ametric (n <> ".count") (Stats.count stats) t
              , ametric (n <> ".sum") (Stats.sum stats) t
              , ametric (n <> ".min") (Stats.min stats) t
              , ametric (n <> ".max") (Stats.max stats) t
              , ametric (n <> ".mean") (Stats.mean stats) t
              , ametric (n <> ".variance") (Stats.variance stats) t
              ]
      _ -> []

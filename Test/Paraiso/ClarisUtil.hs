{-# LANGUAGE NoImplicitPrelude, OverloadedStrings #-}
{-# OPTIONS -Wall #-}
module Test.Paraiso.ClarisUtil (
  evaluate
  ) where

import           Control.Concurrent         (forkIO)
import qualified Data.ListLike as LL
import           Language.Paraiso.Generator (generateIO)
import qualified Language.Paraiso.Generator.Claris as C
import qualified Language.Paraiso.Generator.Native as Native
import           Language.Paraiso.Prelude
import           System.FilePath            ((</>))
import           System.IO                  (hGetLine, hIsEOF, Handle)
import           System.IO.Unsafe           (unsafePerformIO)
import           System.Process             (createProcess, CreateProcess(..),
                                             system, shell, StdStream(..), waitForProcess)
import           System.Random              (randomIO)
import qualified Test.Paraiso.Option as Option


evaluate :: C.Program -> Int    
evaluate prog = unsafePerformIO $ do
  key <- randomIO
  let path :: FilePath
      path = "/tmp/" ++ (show :: Int -> String) key 
      exeFn = path </> "dragon.out" -- roar!
      setup = Native.defaultSetup{ Native.directory = path }
  files <- generateIO setup prog 
  let cppFn :: FilePath
      cppFn = head $ filter (LL.isSuffixOf ".cpp") $ map fst $ files
  _ <- system $ unwords [Option.cppc, "-O3",  cppFn, "-I", path,  "-o",  exeFn]
  (_, Just hout, _, handle) <- createProcess (shell exeFn) {std_out = CreatePipe}
  ret <- fmap (read :: String -> Int) $ hGetLine hout
  _ <- forkIO $ suckAll hout
  _ <- waitForProcess handle
  _ <- system $ "rm -fr " ++ path
  return ret


suckAll :: Handle -> IO ()
suckAll hdl = do
  eof <- hIsEOF hdl
  if eof 
    then return ()
    else hGetLine hdl >> suckAll hdl


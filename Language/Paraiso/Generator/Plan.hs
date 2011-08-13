{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS -Wall #-}

module Language.Paraiso.Generator.Plan (
  Plan(..)
  ) where

import qualified Data.Vector as V
import           Language.Paraiso.Name
import qualified Language.Paraiso.OM.Graph as Graph

data Plan v g a
  = Plan 
    { planName :: Name,
      setup    :: Graph.Setup v g a,
      kernels  :: V.Vector (Graph.Kernel v g a)
    }

instance Nameable (Plan v g a) where name = planName    
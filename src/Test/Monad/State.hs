{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE UndecidableInstances #-}

module Test.Monad.State where

import Control.Monad.State
import Test.QuickCheck

import Test.Checkers

-- * 'MonadState' laws

get_get :: forall m s. (MonadState s m, EqProp (m s)) => Property
get_get = (get >> get) =-= get @_ @m

get_put :: forall m s. (MonadState s m, EqProp (m ())) => Property
get_put = (get >>= put) =-= return @m ()

put_get :: forall m s. (MonadState s m, EqProp (m s)) => s -> Property
put_get s = (put s >> get) =-= (put s >> return @m s)

put_put :: forall m s. (MonadState s m, EqProp (m ())) => s -> s -> Property
put_put s1 s2 = (put s1 >> put s2) =-= put @_ @m s2

-- * Misc

instance (EqProp (m (a, s)), Arbitrary s, Show s)
  => EqProp (StateT s m a) where
  StateT f =-= StateT g = property $ \s -> f s =-= g s

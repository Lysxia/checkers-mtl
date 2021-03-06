{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Test.Monad.State where

import Control.Monad.State
import Test.QuickCheck.HigherOrder (Equation(..))

-- * 'MonadState' laws

-- | 'get' is idempotent.
--
-- @
-- 'get' '>>' 'get' = 'get'
-- @
get_get :: forall m s. MonadState s m => Equation (m s)
get_get = (get >> get) :=: get @_ @m

-- | 'get'/'put' identity. @('get' '>>=' 'put')@ is the same as @('return' ())@.
--
-- @
-- 'get' '>>=' 'put' = 'return' ()
-- @
get_put :: forall m s. MonadState s m => Equation (m ())
get_put = (get >>= put) :=: return @m ()

-- | 'put'/'get' identity. After 'put', the state we 'get' is the state we 'put'.
--
-- @
-- 'put' s '>>' 'get' = 'put' s '>>' 'return' s
-- @
put_get :: forall m s. MonadState s m => s -> Equation (m s)
put_get s = (put s >> get) :=: (put s >> return @m s)

-- | 'put' absorption. @('put' s1 '>>' 'put' s2)@ discards the first 'put'.
--
-- @
-- 'put' s1 '>>' 'put' s2 = 'put' s2
-- @
put_put :: forall m s. MonadState s m => s -> s -> Equation (m ())
put_put s1 s2 = (put s1 >> put s2) :=: put @_ @m s2

-- * Helpers

-- | This is equivalent to 'state', which should be a monad homomorphism.
state' :: forall m a s. MonadState s m => State s a -> m a
state' = state . runState

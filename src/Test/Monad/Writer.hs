{-# LANGUAGE ScopedTypeVariables #-}

module Test.Monad.Writer where

import Data.Functor (($>))
import Control.Monad.Writer
import Test.QuickCheck.HigherOrder (Equation(..))

-- * 'MonadWriter' laws

-- | Telling two values sequentially is equivalent to appending the two values then telling once.
--
-- @
-- 'tell' w1 '>>' 'tell' w2 = 'tell' (w1 '<>' w2)
-- @
tell_tell
  :: forall m w
  .  MonadWriter w m
  => w -> w -> Equation (m ())
tell_tell w1 w2 = (tell w1 >> tell w2) :=: tell (w1 <> w2)

-- | telling a 'mempty' value is equivalent to calling @('return' ())@.
--
-- @
-- 'tell' 'mempty' = 'return' ()
-- @
tell_mempty
  :: forall m w
  .  MonadWriter w m
  => Equation (m ())
tell_mempty = tell mempty :=: return ()

-- | @('listen' . 'return')@ lifts a value into a monad and tuples it with 'mempty'.
--
-- @
-- 'listen' ('return' a) = 'return' (a, 'mempty')
-- @
listen_return
  :: forall m a w
  .  MonadWriter w m
  => a -> Equation (m (a, w))
listen_return a = listen (return a) :=: return (a, mempty)

-- |
-- @
-- 'listen' (m '>>=' k)
-- = 'listen' m     '>>=' \\(a, wa) ->
--   'listen' (k a) '>>=' \\(b, wb) ->
--   'return' (b, wa '<>' wb)
-- @
listen_bind
  :: forall m a b w
  .  MonadWriter w m
  => m a -> (a -> m b) -> Equation (m (b, w))
listen_bind m k =
  listen (m >>= k) :=: do
    (a, wa) <- listen m
    (b, wb) <- listen (k a)
    return (b, wa <> wb)

-- | Lifting 'snd' into @('listen' . 'tell')@ tells a value then lifts it into a monad.
--
-- @
-- 'fmap' 'snd' ('listen' ('tell' w)) = 'tell' w '>>' 'return' w
-- @
listen_tell
  :: forall m w
  .  MonadWriter w m
  => w -> Equation (m w)
listen_tell w =
  fmap snd (listen (tell w)) :=: (tell w >> return w)

-- |
-- @
-- 'listen' ('listen' m) = 'fmap' (\\(a, w) -> ((a, w), w)) ('listen' m)
-- @
listen_listen
  :: forall m a w
  .  MonadWriter w m
  => m a -> Equation (m ((a, w), w))
listen_listen m = listen (listen m) :=: fmap (\(a, w) -> ((a, w), w)) (listen m)

-- |
-- @
-- 'listen' ('pass' m) = 'pass' ('fmap' (\\((a, f), w) -> ((a, f w), f)) ('listen' m))
-- @
listen_pass
  :: forall m a w
  .  MonadWriter w m
  => m (a, w -> w) -> Equation (m (a, w))
listen_pass m =
  listen (pass m) :=: pass (fmap (\((a, f), w) -> ((a, f w), f)) (listen m))

-- | Using 'pass' to modify the value in a 'tell' action is equivalent to
-- modifying the value before applying it to the 'tell' action.
--
-- @
-- 'pass' ('tell' w '$>' ((), f)) = 'tell' (f w)
-- @
pass_tell
  :: forall m w
  .  MonadWriter w m
  => w -> (w -> w) -> Equation (m ())
pass_tell w f =
  pass (tell w $> ((), f)) :=: tell (f w)

-- * Helpers

-- | This is equivalent to 'writer', which should be a monad homomorphism.
writer' :: forall m a w. MonadWriter w m => Writer w a -> m a
writer' = writer . runWriter

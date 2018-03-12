{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module Test.Monad.Reader.Checkers where

import Control.Monad.Reader
import Test.QuickCheck (CoArbitrary, Function, Property)
import Test.QuickCheck.HigherOrder (Constructible, TestEq, ok, ko)

import Test.Monad.Instances ()
import Test.Monad.Morph
import Test.Monad.Reader
import Test.Monad.Reader.Mutants

checkReader
  :: forall m a b r
  .  ( MonadReader r m
     , Show b, Show r
     , Function b, Function r
     , CoArbitrary b, CoArbitrary r
     , Constructible a, Constructible r, Constructible (m a), Constructible (m b)
     , TestEq (m a), TestEq (m r))
  => [(String, Property)]
checkReader =
  [ ok "ask-ask"         (ask_ask @m)
  , ok "local-ask"       (local_ask @m)
  , ok "local-local"     (local_local @m @a)
  , ok "bindHom-local"   (\f -> bindHom @m @_ @b @a (local f))
  , ok "returnHom-local" (\f -> returnHom @m @_ @a (local f))
  ]

checkReader_ :: [(String, Property)]
checkReader_ = checkReader @(Reader Int) @Int @Int

type Mutant1 = MutantReader LocalId Int
type Mutant2 = MutantReaderT LocalRunsTwice Int []

checkReader' :: [(String, Property)]
checkReader' =
  [ ok "mut-1-ask-ask"         (ask_ask @Mutant1)
  , ko "mut-1-local-ask"       (local_ask @Mutant1)
  , ok "mut-1-local-local"     (local_local @Mutant1 @Int)
  , ok "mut-1-bindHom-local"   (\f -> bindHom @Mutant1 @_ @Int @Int (local f))
  , ok "mut-1-returnHom-local" (\f -> returnHom @Mutant1 @_ @Int (local f))

  , ok "mut-2-ask-ask"         (ask_ask @Mutant2)
  , ok "mut-2-local-ask"       (local_ask @Mutant2)
  , ko "mut-2-local-local"     (local_local @Mutant2 @Int)
  , ko "mut-2-bindHom-local"   (\f -> bindHom @Mutant2 @_ @Int @Int (local f))
  , ok "mut-2-returnHom-local" (\f -> returnHom @Mutant2 @_ @Int (local f))
  ]

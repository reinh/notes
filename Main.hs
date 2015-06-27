{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Map                           as M
import qualified Data.Set                           as S
import           Hakyll
import qualified Text.CSL                           as CSL
import           Text.CSL.Pandoc                    (processCites)
import           Text.Pandoc
import           Text.Pandoc.Crossref
import           Text.Pandoc.Crossref.Util.Settings (defaultMeta)
import           Text.Pandoc.Options

main :: IO ()
main = hakyll $ do

    match "bib/bib.bib" (compile biblioCompiler)
    match "bib/csl.csl" (compile cslCompiler)

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "fonts/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ compiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    dateField "shortdate" "%Y.%m.%d" `mappend`
    defaultContext

compiler :: Compiler (Item String)
compiler =
  do
     bib <- load (fromFilePath "bib/bib.bib")
     csl <- load (fromFilePath "bib/csl.csl")
     body <- getResourceBody
     pandoc <- readPandocBiblio' ropts csl bib body
     withItemBody (sidenoteWriter wopts) pandoc
  where
    setMeta :: Pandoc -> Pandoc
    setMeta (Pandoc (Meta meta) blocks) = Pandoc (Meta meta') blocks
      where
        meta' = M.insert "reference-section-title" (MetaString "References") meta

ropts :: ReaderOptions
ropts =
  defaultHakyllReaderOptions

wopts :: WriterOptions
wopts =
  defaultHakyllWriterOptions {writerExtensions = newExtensions
                             ,writerHTMLMathMethod = KaTeX "" ""}
  where extensions =
          [Ext_literate_haskell
          ,Ext_tex_math_dollars
          ,Ext_tex_math_double_backslash
          ,Ext_latex_macros
          ,Ext_inline_code_attributes]
        defaultExtensions = writerExtensions defaultHakyllWriterOptions
        newExtensions =
          foldr S.insert defaultExtensions extensions

sidenoteWriter :: WriterOptions -> Pandoc -> Compiler String
sidenoteWriter wopt pandoc =
  unsafeCompiler (writeCustom "sidenote.lua" wopt pandoc)

readPandocBiblio' :: ReaderOptions
                  -> Item CSL
                  -> Item Biblio
                  -> (Item String)
                  -> Compiler (Item Pandoc)
readPandocBiblio' ropt csl biblio item = do
    -- Parse CSL file, if given
    style <- unsafeCompiler $ CSL.readCSLFile Nothing . toFilePath . itemIdentifier $ csl

    -- We need to know the citation keys, add then *before* actually parsing the
    -- actual page. If we don't do this, pandoc won't even consider them
    -- citations!
    let Biblio refs = itemBody biblio
    pandoc <- setMeta . processWith defaultMeta Nothing . itemBody <$> readPandocWith ropt item
    let pandoc' = processCites style refs pandoc

    return $ fmap (const pandoc') item
  where
    setMeta :: Pandoc -> Pandoc
    setMeta (Pandoc (Meta meta) blocks) = Pandoc (Meta meta') blocks
      where
        meta' = M.insert "link-citations" (MetaBool True)
              $ meta

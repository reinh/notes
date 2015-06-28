#!/bin/bash
git subtree split -P _site -b gh-pages && git push origin gh-pages:gh-pages


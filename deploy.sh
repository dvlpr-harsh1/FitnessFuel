#!/bin/bash

echo "📦 Building Flutter Web..."
flutter build web

echo "📁 Moving build to docs/"
rm -rf docs
mv build/web docs

echo "📝 Committing changes..."
git add .
git commit -m "🚀 Deploy update: Flutter Web rebuild"

echo "🔄 Pulling remote changes (safe rebase)..."
git pull origin main --rebase

echo "📤 Pushing to GitHub..."
git push origin main

echo "✅ Done! Visit your site at:"
echo "🌐 https://dvlpr-harsh1.github.io/FitnessFuel/"

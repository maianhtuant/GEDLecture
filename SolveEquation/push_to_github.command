#!/bin/bash
cd "$(dirname "$0")"

echo "Setting up git..."
git init
git config user.name "Tuan Mai"
git config user.email "maianhtuant@gmail.com"
git branch -M main

echo "Adding files..."
git add .gitignore GEDLecture1.py add_audio.command add_audio.sh main.py

echo "Committing..."
git commit -m "Initial commit: SolveEquation Manim lecture with Google TTS audio script"

echo "Adding remote..."
git remote remove origin 2>/dev/null
git remote add origin https://github.com/maianhtuant/GEDLecture.git

echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "Done! Check: https://github.com/maianhtuant/GEDLecture"

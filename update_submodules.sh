echo "--- Git Submodule Update Tool ---"
echo "This will fetch the latest commits for all submodules based on their configured branch."
echo ""

echo "Updating all submodules..."
git submodule update --remote --merge

if [ $? -ne 0 ]; then
  echo "Error: 'git submodule update' failed. Please check for conflicts within the submodules."
  exit 1
fi
echo "Submodules updated locally."


if [ -z "$(git status --porcelain)" ]; then
  echo "All submodules are already up-to-date. Nothing to commit."
  exit 0
fi

echo "Submodules have new commits. Staging and committing changes..."

git add -u 

COMMIT_MESSAGE="chore: Update submodules to latest commits"
echo "Committing with message: \"$COMMIT_MESSAGE\""
git commit -m "$COMMIT_MESSAGE"

if [ $? -ne 0 ]; then
  echo "Error: Failed to commit changes. Please review 'git status'."
  exit 1
fi
echo "Parent repository updated to track new submodule commits."


read -p "Push changes to origin/main now? (y/N): " -n 1 -r PUSH_CONFIRMATION
echo

if [[ "$PUSH_CONFIRMATION" =~ ^[Yy]$ ]]; then
  echo "Pushing changes to origin/main..."
  git push origin main
  if [ $? -ne 0 ]; then
    echo "Error: Failed to push changes. Please push manually."
    exit 1
  fi
  echo "Changes successfully pushed."
else
  echo "Changes not pushed. Remember to run 'git push' later."
fi

echo ""
echo "--- Submodule Update Process Complete ---"
REPO_URL=$1
LOCAL_PATH=$2
BRANCH_NAME=${3:-main} 

if [ -z "$REPO_URL" ] || [ -z "$LOCAL_PATH" ]; then
  echo "Usage: $0 <repo_url> <local_path> [branch_name]"
  exit 1
fi

echo "--- Git Submodule Addition Tool ---"
echo "Repository URL: $REPO_URL"
echo "Local Path:     $LOCAL_PATH"
echo "Tracking Branch: ${BRANCH_NAME}"
echo "-----------------------------------"
echo ""


echo "Adding submodule..."
git submodule add "$REPO_URL" "$LOCAL_PATH"

if [ $? -ne 0 ]; then
  echo "Error: Failed to add submodule. Exiting."
  exit 1
fi
echo "Submodule added locally."


echo "Setting submodule to track branch '$BRANCH_NAME'..."
if git --version | grep -q "git version 2\.[2-9][2-9]\|git version [3-9]\.[0-9]\."; then
  git submodule set-branch "$BRANCH_NAME" "$LOCAL_PATH"
else
  
  git config -f .gitmodules submodule."$LOCAL_PATH".branch "$BRANCH_NAME"
fi

if [ $? -ne 0 ]; then
  echo "Warning: Failed to set submodule branch. You might need to manually edit .gitmodules."
  
  
  exit 1
fi
echo "Submodule branch configured."


echo "Staging changes to .gitmodules and $LOCAL_PATH..."
git add "$LOCAL_PATH" .gitmodules


DEFAULT_COMMIT_MESSAGE="feat: Add submodule $LOCAL_PATH from $REPO_URL tracking $BRANCH_NAME"
read -p "Enter commit message (default: \"$DEFAULT_COMMIT_MESSAGE\"): " USER_COMMIT_MESSAGE

COMMIT_MESSAGE="${USER_COMMIT_MESSAGE:-$DEFAULT_COMMIT_MESSAGE}" 

echo "Committing changes with message: \"$COMMIT_MESSAGE\""
git commit -m "$COMMIT_MESSAGE"

if [ $? -ne 0 ]; then
  echo "Error: Failed to commit changes. Please review and commit manually."
  exit 1
fi
echo "Changes committed locally."


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
  echo "Changes not pushed. Remember to run 'git push origin main' later."
fi

echo ""
echo "--- Submodule Addition Process Complete ---"
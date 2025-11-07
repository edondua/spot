# 🚨 QUICK FIX: Broken Xcode References

## The Problem

Xcode is looking for files in old locations because we reorganized the project architecture. Files were moved from flat structure to organized folders (Core/, Data/, Presentation/).

## The Solution (5 minutes)

### Step 1: Close Xcode
- Quit Xcode completely (Cmd+Q)

### Step 2: Clean Derived Data
Run this command:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Spotted-*
```

### Step 3: Open Xcode
```bash
cd /Users/doruntinaramadani/Desktop/Spotted
open Spotted.xcodeproj
```

### Step 4: Remove ALL Red Files (Missing References)

In Xcode's Project Navigator (left sidebar), you'll see **RED files** (these are broken references).

**For EACH red file:**
1. Click on it
2. Press `Delete` key
3. In dialog, choose **"Remove Reference"** (NOT "Move to Trash")

**Red files you'll see:**
- All files under old "Models" folder
- All files under old "Views" folder
- All files under old "ViewModels" folder
- All files under old "Services" folder

**Just keep deleting red files until there are none left!**

### Step 5: Re-add All Files

After all red files are removed:

1. **Right-click** the blue "Spotted" folder
2. Select **"Add Files to 'Spotted'..."**
3. In the file picker, select the **"Spotted"** folder (the inner one)
4. **IMPORTANT:** Check these options:
   - ☐ Copy items if needed (UNCHECK)
   - ⦿ Create groups (SELECT)
   - ☐ Create folder references (UNCHECK)
   - ☑ Spotted target (CHECK)
5. Click **"Add"**

This will add ALL files including the new Design System!

### Step 6: Build
Press **Cmd+B**

Should build successfully! ✅

---

## If That Doesn't Work: Nuclear Option

Run this script (will do it all automatically):
```bash
cd /Users/doruntinaramadani/Desktop/Spotted
./nuclear_fix.sh
```

I'll create that script for you now...

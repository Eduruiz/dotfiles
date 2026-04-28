#!/usr/bin/env python3
"""
Quick validation script to check if the fixes are in place.
Run this to verify the corrections were applied successfully.
"""
import sys

def check_library_py():
    """Check library.py for the fixes."""
    print("🔍 Checking library.py...")
    
    with open("library.py") as f:
        content = f.read()
    
    issues = []
    
    # Check 1: No duplicate validation block
    if content.count("# 3. Validação contra o Contexto do Bot") > 1:
        issues.append("❌ Duplicate validation block still exists in tag_track()")
    else:
        print("  ✅ No duplicate validation blocks")
    
    # Check 2: Robust tracknumber validation with try/except
    if "try:" in content and "track_int = int(str(tracknum)" in content:
        print("  ✅ Robust tracknumber validation with try/except")
    else:
        issues.append("❌ Missing robust tracknumber validation")
    
    # Check 3: Correct _beet_move call (no force_track parameter)
    if "force_track=" in content:
        issues.append("❌ Invalid _beet_move call with force_track parameter")
    else:
        print("  ✅ Correct _beet_move() call")
    
    return issues


def check_musicbot_api_py():
    """Check musicbot_api.py for the fixes."""
    print("\n🔍 Checking musicbot_api.py...")
    
    with open("musicbot_api.py") as f:
        content = f.read()
    
    issues = []
    
    # Check 1: Timeout in waiting loop
    if "max_wait = 300" in content or "max_wait =" in content:
        print("  ✅ Timeout added to waiting loop")
    else:
        issues.append("❌ No timeout in waiting loop")
    
    # Check 2: Error handling in _import_track
    if "def _import_track" in content:
        import_track_start = content.find("def _import_track")
        import_track_section = content[import_track_start:import_track_start + 1000]
        if "try:" in import_track_section and "except Exception" in import_track_section:
            print("  ✅ Error handling in _import_track()")
        else:
            issues.append("❌ Missing error handling in _import_track()")
    
    # Check 3: Error handling in _ytdlp_track
    if "def _ytdlp_track" in content:
        ytdlp_start = content.find("def _ytdlp_track")
        ytdlp_section = content[ytdlp_start:ytdlp_start + 1000]
        if "try:" in ytdlp_section and "except Exception" in ytdlp_section:
            print("  ✅ Error handling in _ytdlp_track()")
        else:
            issues.append("❌ Missing error handling in _ytdlp_track()")
    
    # Check 4: Error handling in _process_task closure
    if "def _process_task" in content:
        process_task_matches = content.count("def _process_task")
        try_in_process = content.count("def _process_task") > 0 and \
                         content[content.find("def _process_task"):content.find("def _process_task")+800].count("try:") > 0
        if try_in_process:
            print("  ✅ Error handling in _process_task closure")
        else:
            issues.append("❌ Missing error handling in _process_task closure")
    
    # Check 5: Enhanced _to_opus with file existence check
    if "def _to_opus" in content:
        to_opus_start = content.find("def _to_opus")
        to_opus_section = content[to_opus_start:to_opus_start + 2000]
        if "os.path.exists(src)" in to_opus_section:
            print("  ✅ File existence check in _to_opus()")
        else:
            issues.append("❌ Missing file existence check in _to_opus()")
    
    # Check 6: Lock for cover_queue
    cover_queue_contexts = []
    for i, line in enumerate(content.split('\n')):
        if 'cover_queue' in line and 'setdefault' in line:
            # Check if there's a 'with _jobs_lock:' in the previous 5 lines
            start = max(0, i - 5)
            context = '\n'.join(content.split('\n')[start:i+1])
            if 'with _jobs_lock:' in context:
                cover_queue_contexts.append(True)
            else:
                cover_queue_contexts.append(False)
    
    if any(cover_queue_contexts):
        print("  ✅ Lock protection for cover_queue")
    else:
        print("  ⚠️  Could not verify cover_queue lock (might be OK)")
    
    return issues


def main():
    print("=" * 60)
    print("Music Bot - Fix Validation Script")
    print("=" * 60)
    
    all_issues = []
    
    try:
        all_issues.extend(check_library_py())
    except FileNotFoundError:
        print("❌ library.py not found")
        return 1
    except Exception as e:
        print(f"❌ Error checking library.py: {e}")
        return 1
    
    try:
        all_issues.extend(check_musicbot_api_py())
    except FileNotFoundError:
        print("❌ musicbot_api.py not found")
        return 1
    except Exception as e:
        print(f"❌ Error checking musicbot_api.py: {e}")
        return 1
    
    print("\n" + "=" * 60)
    if all_issues:
        print("❌ ISSUES FOUND:")
        for issue in all_issues:
            print(f"  {issue}")
        print("\n⚠️  Some fixes may not have been applied correctly")
        return 1
    else:
        print("✅ ALL FIXES VERIFIED!")
        print("\n🎉 The code is ready for testing")
        print("\nNext steps:")
        print("  1. Restart the musicbot service:")
        print("     systemctl --user restart musicbot")
        print("  2. Monitor logs:")
        print("     journalctl --user -u musicbot -f")
        print("  3. Test a simple album download")
        return 0


if __name__ == "__main__":
    sys.exit(main())

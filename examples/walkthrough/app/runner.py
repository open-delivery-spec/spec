"""A tiny module that runs a shell command for the user.

This is the *vulnerable* version used by the walkthrough: it passes untrusted
input straight to a shell (command injection). See README.md for the fix.
"""
import subprocess


def run_user_command(user_input):
    # Untrusted input flows into a shell — command injection risk.
    return subprocess.run(user_input, shell=True, capture_output=True)

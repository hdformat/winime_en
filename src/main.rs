#![cfg(windows)]

use clap::Parser;
use windows::Win32::Foundation::HWND;
use windows::Win32::UI::Input::Ime::ImmGetDefaultIMEWnd;
use windows::Win32::UI::WindowsAndMessaging::{
    GetForegroundWindow, GetWindowTextW, SendMessageW, WM_IME_CONTROL,
};

/// A simple CLI to switch the foreground window's IME to English mode.
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Suppress all output.
    #[arg(short, long, default_value_t = false, conflicts_with = "verbose")]
    quiet: bool,

    /// Enable verbose output.
    #[arg(short, long, default_value_t = false)]
    verbose: bool,
}

unsafe fn get_foreground_window_handle() -> Result<HWND, &'static str> {
    let hwnd: HWND = unsafe { GetForegroundWindow() };
    if hwnd.is_invalid() {
        return Err("Failed to get foreground window");
    }
    Ok(hwnd)
}

unsafe fn get_foreground_window_title(hwnd: HWND) -> Result<String, &'static str> {
    let mut buffer: [u16; 512] = [0; 512];
    unsafe { GetWindowTextW(hwnd, &mut buffer) };
    let title = String::from_utf16_lossy(&buffer);
    Ok(title)
}

unsafe fn get_default_ime_window_handle(hwnd: HWND) -> Result<HWND, &'static str> {
    let ime_hwnd: HWND = unsafe { ImmGetDefaultIMEWnd(hwnd) };
    if ime_hwnd.is_invalid() {
        return Err("Failed to get default IME window");
    }
    Ok(ime_hwnd)
}

unsafe fn set_default_ime_to_en_by_sendmessage(hwnd_ime: HWND) -> Result<bool, &'static str> {
    const IMC_GETOPENSTATUS: u32 = 5;
    const IMC_SETOPENSTATUS: u32 = 6;
    const IME_STATUS_ENGLISH: isize = 0;

    let is_english = unsafe { SendMessageW(
        hwnd_ime,
        WM_IME_CONTROL,
        Some(windows::Win32::Foundation::WPARAM(IMC_GETOPENSTATUS as usize)),
        Some(windows::Win32::Foundation::LPARAM(0)),
    ) };

    if is_english.0 == IME_STATUS_ENGLISH {
        return Ok(false); // Already English
    }

    let _ = unsafe { SendMessageW(
        hwnd_ime,
        WM_IME_CONTROL,
        Some(windows::Win32::Foundation::WPARAM(IMC_SETOPENSTATUS as usize)),
        Some(windows::Win32::Foundation::LPARAM(IME_STATUS_ENGLISH)),
    ) };

    Ok(true) // Switched to English
}

fn main() -> windows::core::Result<()> {
    let args = Args::parse();

    unsafe {
        let hwnd = match get_foreground_window_handle() {
            Ok(hwnd) => {
                if args.verbose {
                    println!("[O] foreground window's handle: {:?}", hwnd);
                }
                hwnd
            }
            Err(error) => {
                if !args.quiet {
                    eprintln!("[X] Error: {}", error);
                }
                return Ok(());
            }
        };

        if args.verbose {
            if let Ok(title) = get_foreground_window_title(hwnd) {
                println!("[O] foreground window's title: {}", title.trim_end());
            }
        }

        let hwnd_ime = match get_default_ime_window_handle(hwnd) {
            Ok(hwnd_ime) => {
                if args.verbose {
                    println!("[O] foreground window's default IME window handle: {:?}", hwnd_ime);
                }
                hwnd_ime
            }
            Err(error) => {
                if !args.quiet {
                    eprintln!("[X] Error: {}", error);
                }
                return Ok(());
            }
        };

        match set_default_ime_to_en_by_sendmessage(hwnd_ime) {
            Ok(false) => {
                if !args.quiet {
                    println!("[-] foreground window's default IME is already English");
                }
            }
            Ok(true) => {
                if !args.quiet {
                    println!("[O] foreground window's default IME switched to English");
                }
            }
            Err(error) => {
                if !args.quiet {
                    eprintln!("[X] Error: {}", error);
                }
            }
        }
    }

    Ok(())
}

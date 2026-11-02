winime_en
====

윈도우 입력기 상태를 영어로 전환 시켜주는 CLI 도구입니다. 
윈도우에서 작동하며 WSL2 환경에서도 사용 가능합니다.

네오빔 한글 입력 중 노멀모드 진입 시 불편함이 있어 제작하였습니다.

## 설치

### 인스톨러

[Releases](https://github.com/hdformat/winime_en/releases)에서 `winime_en-Setup-<version>.exe`를 다운로드하여 실행합니다.

### 소스 빌드

**Windows 환경에서만 빌드 가능합니다.**

```pwsh
PS > cargo build --release
```

```pwsh
PS > gci .\target\release\*.exe | select name

Name          
----          
winime_en.exe 
```

## 사용법

### 직접 실행

**Windows**
```pwsh
PS > winime_en.exe # 한글
[O] foreground window's default IME switched to English

PS > winime_en.exe # English
[-] foreground window's default IME is already English
```

**WSL2**
```bash
$ /mnt/c/path/to/winime_en.exe    
```

### Neovim 연동

**'/path/to/' 는 실제 경로로 변경**
```lua
-- init.lua (Windows)
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  callback = function()
    vim.fn.system('c:/path/to/winime_en.exe')
  end,
})

-- init.lua (WSL2)
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  callback = function()
    vim.fn.system('/mnt/c/path/to/winime_en.exe')
  end,
})
```


" Initialize the channel
if !exists('s:calculatorJobId')
	let s:calculatorJobId = 0
endif

" Constants for RPC messages.
let s:Add = 'add'
let s:Multiply = 'multiply'

" The path to the binary that was created out of 'cargo build' or 'cargo build --release". This will generally be 'target/release/name'
let s:bin = '/Users/srishanbhattarai/Documents/code/rust/neovim-calculator/target/debug/neovim-calculator'

" Entry point. Initialize RPC. If it succeeds, then attach commands to the `rpcnotify` invocations.
function! s:connect()
  let id = s:initRpc()
  
  if 0 == id
    echoerr "calculator: cannot start rpc process"
  elseif -1 == id
    echoerr "calculator: rpc process is not executable"
  else
    " Mutate our jobId variable to hold the channel ID
    let s:calculatorJobId = id 
    
    call s:configureCommands()
  endif
endfunction

function! s:configureCommands()
  " command! -nargs=0 SpotifyCurrentSong :call s:rpc(s:CurrentSong)
  command! -nargs=+ Add :call s:add(<f-args>)
  command! -nargs=+ Multiply :call s:multiply(<f-args>)
endfunction

function! s:add(...)
  let s:p = get(a:, 1, 0)
  let s:q = get(a:, 2, 0)

  call rpcnotify(s:calculatorJobId, s:Add, str2nr(s:p), str2nr(s:q))
endfunction

function! s:multiply(...)
  let s:p = get(a:, 1, 1)
  let s:q = get(a:, 2, 1)

  call rpcnotify(s:calculatorJobId, s:Multiply, str2nr(s:p), str2nr(s:q))
endfunction

" Initialize RPC
function! s:initRpc()
  if s:calculatorJobId == 0
    let jobid = jobstart([s:bin], { 'rpc': v:true })
    return jobid
  else
    return s:calculatorJobId
  endif
endfunction

call s:connect()

## Go compatibility layer for transpiled Go code
##
## Multi-backend implementation selected at compile time:
##   -d:gocompat=libdill   Use libdill (structured concurrency)
##   -d:gocompat=golib     Use golib-nim (real Go channels via gccgo)
##   -d:gocompat=stub      Use stub (default, for testing)
##
## Usage:
##   nim c -d:gocompat=libdill --passL:-ldill yourfile.nim
##   nim c -d:gocompat=golib --gc:go yourfile.nim

const GocompatBackend* {.strdefine.} = "stub"

when GocompatBackend == "libdill":
  # ==========================================================================
  # libdill Backend - Real structured concurrency
  # ==========================================================================
  import std/[os, posix]

  const libdillPath = getEnv("HOME") & "/prog/libdill_nim/libdill"

  when fileExists(libdillPath & ".nim"):
    include libdillPath
  else:
    {.error: "libdill binding not found at: " & libdillPath & ".nim".}

  type
    GoChan*[T] = tuple[send: Handle, recv: Handle]
      ## Go channel - maps to libdill bidirectional channel pair

  proc newGoChan*[T](size: int = 0): GoChan[T] =
    ## Create a Go-style channel
    ## Note: libdill channels are unbuffered, size parameter ignored
    var chv: array[2, cint]
    if chmake(chv) != 0:
      raise newException(IOError, "Failed to create channel")
    result = (send: chv[0], recv: chv[1])

  proc goSend*[T](ch: GoChan[T], value: T) =
    ## Send a value on a channel (blocking)
    var val = value
    if chsend(ch.send, addr val, csize_t(sizeof(T)), DillForever) != 0:
      raise newException(IOError, "Channel send failed")

  proc goRecv*[T](ch: GoChan[T]): T =
    ## Receive a value from a channel (blocking)
    if chrecv(ch.recv, addr result, csize_t(sizeof(T)), DillForever) != 0:
      raise newException(IOError, "Channel receive failed")

  proc goClose*[T](ch: GoChan[T]) =
    ## Close a channel
    discard chdone(ch.send)
    discard chdone(ch.recv)

  # Select using libdill's choose()
  template goSelect*(body: untyped): untyped =
    ## Go select statement using libdill
    ## Stub: executes cases sequentially (TODO: implement with choose())
    body

  template goCase*(op: untyped, body: untyped): untyped =
    ## Select case without variable binding
    discard op
    body

  template goCase*(op: untyped, varName: untyped, body: untyped): untyped =
    ## Select case with variable binding
    let varName = op
    body

  template goDefault*(body: untyped): untyped =
    ## Select default case
    body

elif GocompatBackend == "golib":
  # ==========================================================================
  # golib-nim Backend - Real Go channels via gccgo
  # ==========================================================================
  import golib

  # Re-export golib's channel type as GoChan
  type GoChan*[T] = chan[T]

  # Channel creation - maps to make_chan
  template newGoChan*[T](size: int = 0): GoChan[T] =
    make_chan(T, cint(size))

  # Channel operations - use golib's operators
  template goSend*[T](ch: GoChan[T], value: T) =
    ch <- value

  template goRecv*[T](ch: GoChan[T]): T =
    <-ch

  template goClose*[T](ch: GoChan[T]) =
    close(ch)

  # Select - use golib's select/scase macros
  template goSelect*(body: untyped): untyped =
    select:
      body

  # Transform goCase to scase - this is tricky because we need to unwrap the call
  # For now, use template overloading
  template goCase*(op: untyped, body: untyped): untyped =
    scase op:
      body

  template goCase*(op: untyped, varName: untyped, body: untyped): untyped =
    scase (varName = op):
      body

  template goDefault*(body: untyped): untyped =
    default:
      body

else:
  # ==========================================================================
  # Stub Backend (default) - For compilation testing
  # ==========================================================================
  type
    GoChan*[T] = ref object
      ## Go channel type - placeholder implementation
      data: seq[T]
      closed: bool

  proc newGoChan*[T](size: int = 0): GoChan[T] =
    ## Create a new Go-style channel
    ## size = 0 for unbuffered, > 0 for buffered
    new(result)
    result.data = @[]
    result.closed = false

  proc goSend*[T](ch: GoChan[T], value: T) =
    ## Send a value to a channel (blocking)
    ## Stub: just appends to internal buffer
    if ch.closed:
      raise newException(IOError, "send on closed channel")
    ch.data.add(value)

  proc goRecv*[T](ch: GoChan[T]): T =
    ## Receive a value from a channel (blocking)
    ## Stub: returns default value if empty
    if ch.data.len > 0:
      result = ch.data[0]
      ch.data.delete(0)
    else:
      result = default(T)

  proc goTryRecv*[T](ch: GoChan[T]): tuple[value: T, ok: bool] =
    ## Try to receive without blocking
    ## Returns (value, true) if successful, (default, false) if channel empty
    if ch.data.len > 0:
      result = (ch.data[0], true)
      ch.data.delete(0)
    else:
      result = (default(T), false)

  proc goTrySend*[T](ch: GoChan[T], value: T): bool =
    ## Try to send without blocking
    ## Returns true if successful
    if ch.closed:
      return false
    ch.data.add(value)
    return true

  proc goClose*[T](ch: GoChan[T]) =
    ## Close a channel
    ch.closed = true

  proc goClosed*[T](ch: GoChan[T]): bool =
    ## Check if channel is closed
    ch.closed

  proc goLen*[T](ch: GoChan[T]): int =
    ## Get number of elements in channel buffer
    ch.data.len

  # Select statement support - macro-based API
  #
  # Usage:
  #   goSelect:
  #     goCase ch.goRecv() as msg:
  #       echo "received: ", msg
  #     goCase ch2.goSend(value):
  #       echo "sent"
  #     goDefault:
  #       echo "no communication"

  template goSelect*(body: untyped): untyped =
    ## Go select statement - executes one ready case
    ## Stub: executes all cases sequentially (not true select semantics)
    body

  template goCase*(op: untyped, body: untyped): untyped =
    ## Select case without variable binding
    discard op
    body

  template goCase*(op: untyped, varName: untyped, body: untyped): untyped =
    ## Select case with variable binding (msg := <-ch pattern)
    let varName = op
    body

  template goDefault*(body: untyped): untyped =
    ## Select default case
    body

# =============================================================================
# Common API (available in all backends)
# =============================================================================

# Goroutine support
template go*(body: untyped): untyped =
  ## Launch a goroutine
  ## Stub: runs synchronously (TODO: implement with spawn/async)
  body

# Defer support (Go defer has LIFO semantics, same as Nim)
template goDefer*(body: untyped): untyped =
  ## Go defer statement
  defer: body

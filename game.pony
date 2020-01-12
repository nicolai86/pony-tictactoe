primitive Accepted
primitive Denied

primitive Circle
    fun string(): String val =>
        "o".clone()
primitive Cross
    fun string(): String val =>
        "x".clone()

// Mark defines the two players in Tic-Tac-Toe
type Mark is (Circle | Cross)

type Result is (Accepted | Denied)

// StateListener is used to inform listeners of status updates
interface StateListener
    fun val updated(brd: Board box)

class TicTacToe is InputNotify
    let _env: Env
    var _buffer: Array[U8 val] ref
    var _current: Mark
    var _board: Board ref
    let _listener: StateListener val

    new iso create(env': Env, board': Board iso, listener': StateListener val) =>
        _env = env'
        _buffer = []
        _current = Circle
        _board = consume board'
        _listener = listener'
        _listener.updated(_board)

    fun ref apply(data: Array[U8 val] iso) =>
        let d: Array[U8 val] val = consume data
        try
            if d(0)? == 10 then
                if _buffer.size() > 2 then
                    _env.out.print("too long input. Please retry")
                    _buffer.clear()
                    return
                end
                let inp = readCellState()?
                if inp is None then
                    _env.out.print("Unable to decode input. Please retry")
                    _buffer.clear()
                    return
                end
                _buffer.clear()
                let res = _board.set(inp, _current)
                if res is Denied then
                    _env.out.print("Move not accepted. Please try again")
                    return
                end
                _listener.updated(_board)

                if _board.didWin(_current)? then
                    _env.out.print(_current.string() + " won.")
                    _env.out.print("Game over")
                    _env.input.dispose()
                    return
                end

                if _current is Circle then
                    _current = Cross
                else
                    _current = Circle
                end

                if _board.isFull()? then
                    _env.out.print("Tied.")
                    _env.out.print("Game over")
                    _env.input.dispose()
                    return
                end
            else
                for m in d.values() do
                    _buffer.push(m)
                end
            end
        end

    fun readCellState(): Address? =>
        let s: String ref = String()
        s.append(_buffer)
        s.upper_in_place()

        let rowNum: U8 = s.shift()?
        var row: Row = A
        if rowNum == 0x41 then
            row = A
        elseif rowNum == 0x42 then
            row = B
        elseif rowNum == 0x43 then
            row = C
        end
        let column: USize = USize.from[U8](s.u8()?)
        (row, column)

    fun ref dispose() =>
        None

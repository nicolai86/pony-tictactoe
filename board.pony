use "collections"

// CellState represents the possible states of a Board
type CellState is (Mark | None)

primitive A
    fun idx(): USize => 0
primitive B
    fun idx(): USize => 1
primitive C
    fun idx(): USize => 2

type Row is (A | B | C)

// Address is a location inside the Board
type Address is (Row, USize)


class Board
    let _env: Env
    let _data: Array[Array[CellState val] ref] ref

    new iso create(env': Env) =>
        _env = env'
        _data = [[None; None; None];[None; None; None];[None; None; None]]

    fun isFull(): Bool? =>
        for j in Range(0, 3) do
            for i in Range(0, 3) do
                if _data(j)?(i)? is None then
                    return false
                end
            end
        end
        true

    fun didWin(m: Mark): Bool? =>
        for j in Range(0, 3) do
            var fullRow: Bool = true
            var fullColumn: Bool = true
            for i in Range(0, 3) do
                fullRow = fullRow and (_data(j)?(i)? is m)
                fullColumn = fullColumn and (_data(i)?(j)? is m)
            end
            if fullRow or fullColumn then
                return true
            end
        end
        let tlToBr = (_data(0)?(0)? is m) and (_data(1)?(1)? is m) and (_data(2)?(2)? is m)
        let trToBl = (_data(2)?(0)? is m) and (_data(1)?(1)? is m) and (_data(2)?(0)? is m)
        tlToBr or trToBl

    fun ref set(x: Address val, state: CellState): Result =>
        if x._1.idx() > _data.size() then
            return Denied
        end
        try
            let line: Array[CellState val] = _data(x._1.idx())?
            let y: USize = x._2 - 1
            if y > line.size() then
                return Denied
            end
            let active: CellState val = line(y)?
            if active isnt None then
                return Denied
            end
            line(y)? = state
            _data(x._1.idx())? = line
        else
            return Denied
        end
        Accepted

    fun box at(x: Address val): CellState =>
        try
            _data(x._1.idx())?(x._2)?
        else
            None
        end

class BoardPrinter
    let _out: OutStream tag
    new create(out': OutStream tag) =>
        _out = out'

    fun box updated(board: Board box) =>
        let rows = ["A"; "B"; "C"]
        try
            _out.print("   1 2 3")
            for j in [A; B; C].values() do
                var line = rows(j.idx())? + " ["
                for i in Range(0, 3) do
                    let current = board.at((j, i))
                    line = line + if current is None then " " else current.string() end
                    if i < 2 then
                        line = line + ","
                    end
                end
                _out.print(line + "]")
            end
        end
        _out.print("")

actor Main
    new create(env: Env) =>
        let board: Board iso = Board(env)
        env.out.print("TicTacToe starting...")
        let printer: BoardPrinter val = recover BoardPrinter(env.out) end
        let game: TicTacToe iso = TicTacToe(env, consume board, consume printer)
        env.input(consume game)

alpha = /[A-Za-z]/
alphan = /\w/

parse = (str) ->
    tokens = []

    strLen = str.length
    pos = 0
    # Пропускаем начальные пробелы
    pos++ while pos < strLen and str[pos] == ' '

    while pos < strLen
        # Выделяем очередной токен
        char =  str[pos]
        switch char
            when '+' then tokens.push("+")
            when '-' then tokens.push("-")
            when '*' then tokens.push("*")
            when '/' then tokens.push("/")
            when '(' then tokens.push("(")
            when ')' then tokens.push(")")
            else
                if alpha.test(char)
                    # Выделяем идентификатор
                    end = pos + 1
                    end++ while end < strLen and alphan.test(str[end])
                    tokens.push(str.substr(pos, end - pos))
                    pos = end - 1
                else
                    console.log("Недопустимый символ")
        pos++

        # Пропускаем пробелы
        pos++ while pos < strLen and str[pos] == ' '

    tokens

t = parse("a0 + b1 + c * d")
console.log(t)

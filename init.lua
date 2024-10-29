local http = require("socket.http")
local json = require("json")
local ltn12 = require("ltn12")

local function parse_csv_line(line)
    local fields = {}
    for field in string.gmatch(line, '[^,]+') do
        table.insert(fields, field:match("^%s*(.-)%s*$"))
    end

    return {
        zipCode = fields[1] or "",
        city = fields[2] or "",
        name = fields[3] or "",
        code = fields[4] or "",
        county = fields[5] or "",
        country = fields[6] or ""
    }
end

local function read_csv(filename)
    local data = {}
    local file = io.open(filename, 'r')

    if not file then
        print("Could not open the file " .. filename)
        return data
    end

    local _ = file:read("*l")

    for line in file:lines() do
        if line ~= "" then
            table.insert(data, parse_csv_line(line))
        end
    end

    file:close()
    return data
end

local function httpPost(url, postData)
    local body = {}
    print(url)


    local res, code = http.request {
        method = "POST",
        url = url,
        source = ltn12.source.string(json.encode(postData)),
        headers = {
            ["content-type"] = "application/json",
        },
        sink = ltn12.sink.table(body)
    }

    if type(code) == 'string' then
        print(code)
        return
    end

    if not code or (code >= 400 and code < 600) then
        print("HTTP request failed" .. res)
        return
    end
end

local function init()
    local csv_path = ''
    local url = ''
    local exit = false

    while exit ~= 'y' do
        print('Enter path of csv file')
        io.write("> ")
        csv_path = io.read() .. '.csv'


        print('Enter url of api')
        io.write("> ")
        url = io.read()

        local csv_data = read_csv(csv_path)
        httpPost(url, csv_data)


        print('Exit? Type "y" to exit')
        io.write("> ")
        exit = io.read()
    end
end

init()
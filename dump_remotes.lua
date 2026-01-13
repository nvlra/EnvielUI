local function DumpRemotes()
    local count = 0
    local output = {}
    
    table.insert(output, "=== REMOTE DUMP START ===")
    
    local function Scan(root)
        for _, v in pairs(root:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local info = "Name: " .. v.Name .. " | Class: " .. v.ClassName .. " | Path: " .. v:GetFullName()
                print(info)
                table.insert(output, info)
                count = count + 1
            end
        end
    end
    
    print("Scanning ReplicatedStorage...")
    Scan(game:GetService("ReplicatedStorage"))
    
    print("Scanning Workspace...")
    Scan(game:GetService("Workspace"))
    
    table.insert(output, "=== REMOTE DUMP END: " .. count .. " Found ===")
    
    if setclipboard then
        setclipboard(table.concat(output, "\n"))
        print("Dump copied to clipboard!")
    end
end

DumpRemotes()

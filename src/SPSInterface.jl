VERSION >= v"0.4.0-dev+6521" && __precompile__()
module SPSInterface

using SPSBase
export importFile, exportFile, Schedule, Employee

_is_comment(line::AbstractString) = isempty(line) || startswith(line, '%')
_is_secHeader(line::AbstractString) = startswith(line, '#')

const match_doubleHead = r"##\s*([^#]+)"
const match_singleHead = r"#\s*([^#]+)"
function importFile(path::AbstractString)
    parsingOverallSchedule = false
    overallSchedule = Dict(i => Tuple{Float64, Float64}[] for i in 1:5)
    
    parsingEmployee = false
    tmpEmployeeName = ""
    tmpEmployeeAvail = SPSBase.emptySchedule(Float64)

    employees = Employee[]
    currLineNumber = 0
    for line in map(strip, eachline(path))
        currLineNumber += 1
        _is_comment(line) && continue
        if _is_secHeader(line)
            if parsingEmployee
                # Finalize employee parsing
                parsingEmployee = false
            elseif parsingOverallSchedule
                # Finalize overall schedule
                parsingOverallSchedule = false
            end

            # Continue parsing file
            singleHeadMatch = match(match_singleHead, line)
            doubleHeadMatch = match(match_doubleHead, line)
            
            if doubleHeadMatch != nothing
                # New employee
                info("Found new employee: $(doubleHeadMatch[1])")
                parsingEmployee = true
                tmpEmployeeName = doubleHeadMatch[1]
                tmpEmployeeAvail = SPSBase.emptySchedule(Float64)
            elseif singleHeadMatch != nothing
                # New section (either Overall, Availability, or other...)
                info("Parsing new section: $(singleHeadMatch[1])")
                if singleHeadMatch[1] == "Overall"
                    parsingOverallSchedule = true
                end
            else
                warn("Header not recognized on line $(currLineNumber): ", line)
            end
        elseif parsingEmployee
            println("Employeeline: $(tmpEmployeeName): $(line)")
        elseif parsingOverallSchedule
            println("Osched: $(line)")
        else
            warn("Line $(currLineNumber) not parsed: ", line)
        end
    end
    overallSchedule, employees
end
function exportFile(path::AbstractString, bsl::BitScheduleList)

end

end # module
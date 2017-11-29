VERSION >= v"0.4.0-dev+6521" && __precompile__()
module SPSInterface

using SPSBase
export importFile, exportFile, Schedule, Employee, BitScheduleList

_is_comment(line::AbstractString) = isempty(line) || startswith(line, '%')
_is_secHeader(line::AbstractString) = startswith(line, '#')

const match_tripleHead = r"###\s*([^#]+)"
const match_doubleHead = r"##\s*([^#]+)"
const match_singleHead = r"#\s*([^#]+)"
function importFile(path::AbstractString)
    parsingOverallSchedule = false
    overallSchedule = Dict(i => Tuple{Float64, Float64}[] for i in 1:5)

    parsingEmployee = false
    parsingAvailability = false
    tmpEmployeeName = ""
    tmpEmployeeMaxHours = Inf
    tmpEmployeeSpecialty = 0
    tmpEmployeeAvail = SPSBase.emptySchedule(Float64)

    employees = Employee{Float64}[]
    currLineNumber = 0
    for line in map(strip, eachline(path))
        currLineNumber += 1
        _is_comment(line) && continue
        if _is_secHeader(line)
            if parsingEmployee
                # Finalize employee parsing
                parsingEmployee = false
                if !isempty(tmpEmployeeAvail)
                    push!(employees, Employee(String(tmpEmployeeName), tmpEmployeeAvail, tmpEmployeeMaxHours, tmpEmployeeSpecialty))
                end
                tmpEmployeeName = ""
                tmpEmployeeMaxHours = Inf
                tmpEmployeeAvail = SPSBase.emptySchedule(Float64)
            elseif parsingOverallSchedule
                # Finalize overall schedule
                parsingOverallSchedule = false
            end

            # Continue parsing file
            singleHeadMatch = match(match_singleHead, line)
            doubleHeadMatch = match(match_doubleHead, line)
            tripleHeadMatch = match(match_tripleHead, line)

            # Currently no subsubsections should be parsed
            if tripleHeadMatch != nothing
                continue
            end

            if parsingAvailability && doubleHeadMatch != nothing
                # New employee
                # info("Found new employee: $(doubleHeadMatch[1])")
                parsingEmployee = true
                tmpEmployeeName = doubleHeadMatch[1]
                tmpEmployeeAvail = SPSBase.emptySchedule(Float64)
            elseif singleHeadMatch != nothing
                # New section (either Overall, Availability, or other...)
                # info("Parsing new section: $(singleHeadMatch[1])")
                if singleHeadMatch[1] == "Overall"
                    parsingOverallSchedule = true
                elseif singleHeadMatch[1] == "Availability"
                    parsingAvailability = true
                else
                    parsingOverallSchedule = false
                    parsingAvailability = false
                end
            end
        elseif parsingEmployee
            line = lowercase(line)
            if is_schedline(line)
                parse_SchedLine!(tmpEmployeeAvail, line)
            elseif startswith(line, "maxhours")
                tmpEmployeeMaxHours = min(parse(Float64, line[9:end]), tmpEmployeeMaxHours)
            elseif startswith(line, "specialtycode")
                tmpEmployeeSpecialty = parse(Int, line[14:end])
            end
        elseif parsingOverallSchedule
            line = lowercase(line)
            if is_schedline(line)
                parse_SchedLine!(overallSchedule, line)
            end
        end
    end
    if parsingEmployee
        # Finalize employee parsing
        if !isempty(tmpEmployeeAvail)
            push!(employees, Employee(String(tmpEmployeeName), tmpEmployeeAvail, tmpEmployeeMaxHours, tmpEmployeeSpecialty))
        end
        tmpEmployeeName = ""
        tmpEmployeeMaxHours = Inf
        tmpEmployeeAvail = SPSBase.emptySchedule(Float64)
        tmpEmployeeSpecialty = 0
    end
    overallSchedule, employees
end

const dayMap = Dict('m' => 1, 't' => 2, 'w' => 3, 'r' => 4, 'f' => 5)

function is_schedline(line)
    for d in keys(dayMap)
        startswith(line, "$d ") && return true
    end
    return false
end

function parse_SchedLine!(sched::Schedule{T}, line) where {T}
    times = line[3:end]
    timesout = _parse_SchedLine(times)
    append!(getfield(sched, dayMap[line[1]]), timesout)
end
function parse_SchedLine!(sched::Dict{Int, Vector{Tuple{Float64, Float64}}}, line)
    timesout = _parse_SchedLine(line[3:end])
    sched[dayMap[line[1]]] = timesout
end
function _parse_SchedLine(line)
    map(_parse_timeSpan ∘ strip, split(line, [',']))
end
function _parse_timeSpan(line)
    tuple(map(_parse_time, split(line, "-"))...)
end
function _parse_time(line)::Float64
    if contains(line, ":")
        h, m = split(line, ':')
        parse(Int, h) + parse(Int, m)//60
    else
        parse(Int, line)
    end
end

# File Export
function exportFile(path::AbstractString, bsl::BitScheduleList{T}) where {T}
    exportFile(path, SPSBase.to_sched(bsl))
end
function exportFile(path, empList::EmployeeList{T}) where {T}
    open(path, "w") do st
        for emp in empList
            println(st, "## $(emp.name)")
            if emp.maxTime != Inf
                println(st, "MaxHours $(emp.maxTime)")
            end
            if emp.specialty != 0
                println(st, "SpecialtyCode $(emp.specialty)")
            end
            _exportSched(st, avail(emp))
            print(st, "\n\n")
        end
    end
    return nothing
end

function _exportSched(st::IO, s::Schedule{T}) where {T}
    print(st, "M ")
    _exportSchedDay(st, s.day1)
    print(st, "\nT ")
    _exportSchedDay(st, s.day2)
    print(st, "\nW ")
    _exportSchedDay(st, s.day3)
    print(st, "\nR ")
    _exportSchedDay(st, s.day4)
    print(st, "\nF ")
    _exportSchedDay(st, s.day5)
    return nothing
end
_exportSchedDay(st::IO, d) = join(st, map(_show_span, d), ", ")
_show_span(s) = join(map(_nearest_frac_time, s), "-")

function _nearest_frac_time(t)
    h = floor(Int, t)
    m = floor(Int, 60*(t - h))
    if m == 0
        @sprintf "%d" h
    else
        @sprintf "%d:%d" h m
    end
end
end # module

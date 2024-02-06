using ArgParse # Might switch to some other package
using LeakageAssessment


function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        #"--output"
        #    help = "file name for SNR.png result"
        "--bytes"
            arg_type = Int
            nargs = '+'
            help = "bytes to be processed"
        "textin"
            help = "textin (.npy file)"
            required = true
        "traces"
            help = "traces (.npy file)"
            required = true
    end
    return parse_args(s)
end

function main()
    # parse arguments
    args = parse_commandline()

    # load data
    textin = loaddata(args["textin"])
    traces = loaddata(args["traces"])
    if !isnothing(args["bytes"])
        textin = textin[args["bytes"],:]
    end

    # run NICV
    nicvs = NICV(textin, traces)

    # plot NICV
    println("plotting NICV result...                  \r")
    plotNICV(nicvs, traces)
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

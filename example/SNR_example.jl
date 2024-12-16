using ArgParse # Might switch to some other package
using LeakageAssessment
using LeakageAssessment: loaddata

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
    traces = loaddata(args["traces"])
    textin = isempty(args["bytes"]) ? loaddata(args["textin"]) :
                                      loaddata(args["textin"])[args["bytes"],:]
    # run SNR
    snrs = SNR(textin, traces)

    # plot SNR
    println("plotting SNR result...                  \r")
    plotSNR(snrs, traces)
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

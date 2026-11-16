# Option completion for Quartus/Questa tools, which ship none. Options are
# parsed from each tool's own help text on first use and cached per binary, so
# a package upgrade (new store path) refreshes them.

function __hdl_help_options --argument-names tool
    set -l bin (command -s $tool); or return
    set -l cache $HOME/.cache/hdl-completions/(string replace --all / _ $bin)
    if not test -s $cache
        mkdir -p (path dirname $cache)
        # Run in a scratch directory: Questa tools write a log file to the cwd.
        set -l scratch (mktemp -d)
        switch $tool
            case vlog vcom vopt vsim qrun
                pushd $scratch; $bin -help all 2>&1 | string replace --regex '^# ' '' >$cache.raw; popd
            case vrun
                pushd $scratch; $bin -help >$cache.raw 2>&1; popd
            case '*'
                pushd $scratch; $bin --help >$cache.raw 2>&1; popd
        end
        rm -rf $scratch
        # The option spec ends at the first run of 2+ spaces; the rest is the
        # description. Quartus lines are option specs only, so a spec may hold
        # alternatives such as "-c <rev> | --rev=<rev>".
        for line in (string match --regex -- '^\s*--?[A-Za-z].*' <$cache.raw)
            set -l parts (string match --regex --groups-only -- '^\s*(.*?)(?:\s{2,}(.*))?$' $line)
            set -l desc (string sub --length 60 -- $parts[2])
            for opt in (string match --all --regex --groups-only -- '(?:^|\s\|\s)(--?[A-Za-z][\w.-]*)' $parts[1])
                printf '%s\t%s\n' $opt $desc
            end
        end | sort --unique --field-separator \t --key 1,1 >$cache
        rm -f $cache.raw
    end
    cat $cache
end

for tool in vlog vcom vopt vsim qrun vrun \
        quartus_sh quartus_map quartus_fit quartus_asm quartus_sta quartus_pgm quartus_cpf \
        quartus_eda quartus_drc quartus_cdb quartus_sim quartus_syn quartus_pow quartus_si \
        quartus_stp quartus_hps quartus_dse quartus_npp quartus_py quartus_jli \
        jtagconfig nios2-terminal nios2-flash-programmer nios2-gdb-server openocd
    complete --command $tool --condition 'string match --quiet -- "-*" (commandline --current-token)' --arguments '(__hdl_help_options '$tool')'
end

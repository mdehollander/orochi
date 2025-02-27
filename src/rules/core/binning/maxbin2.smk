
#rule maxbin:
#    input:
#        contigs = "scratch/assembly/megahit/minimus2/all.merged.contigs.fasta",
#        coverage = "results/stats/coverage/coverage.tsv"
#    output:
#        directory("results/binning/maxbin/intermediate_files"),
#        "results/binning/maxbin/bin1.fasta"
#    params:
#        output_prefix = "results/binning/maxbin"
#    conda:
#        "../../../envs/maxbin2.yaml"
#    threads:
#        40
#    shell:
#        """
#        mkdir {output[0]} 2> {log}
#       run_MaxBin.pl -contig {input.contigs} \
#            -abund {input.coverage} \
#            -out {params.output_prefix} \
#            -thread {threads}
#        """


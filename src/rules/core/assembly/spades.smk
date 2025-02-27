if config['assembler']=='spades':
    rule spades:
        input:
            forward = "scratch/treatment/{treatment}_forward.fastq",
            rev = "scratch/treatment/{treatment}_rev.fastq",
    #        unpaired = "scratch/treatment/{treatment}_unpaired.fastq"
        output:
            temp("scratch/assembly/spades/{treatment}/{kmers}/contigs.fasta")
        params:
            outdir= os.path.dirname(str(output)),
            kmers = lambda wildcards: config["assembly-klist"][wildcards.kmers]
        log:
            "logs/assembly/spades/{treatment}/{kmers}/spades.log"
        threads: 80
        conda:
            "../../../envs/spades.yaml"
        shell: "metaspades.py -m 1200 -1 {input.forward} -2 {input.rev} --only-assembler -k {params.kmers} -t {threads} -o {params.outdir} --tmp-dir {params.outdir}/tmp/ 2>&1 > /dev/null"

    rule rename_spades:
        input:
            "scratch/assembly/spades/{treatment}/{kmers}/contigs.fasta"
        output:
            gzip=protected("scratch/assembly/spades/{treatment}/{kmers}/assembly.fa.gz"),
            fasta=temp("scratch/assembly/spades/{treatment}/{kmers}/assembly.fa")
        log:
            "logs/assembly/spades/{treatment}/{kmers}/rename_spades.log"
        run:
            shell("cat {input} | awk '{{print $1}}' | sed 's/_/contig/' > {output.fasta} 2> {log}")
            shell("gzip -c {output.fasta} > {output.gzip}")


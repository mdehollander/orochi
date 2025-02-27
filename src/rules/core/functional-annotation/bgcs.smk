rule filter_contigs_antismash:
    input:
        "scratch/assembly/megahit/minimus2/primary.contigs.fa"
    output:
        temp("scratch/annotation/antismash/secondary.contigs.fa")
    params:
        length=config["filter_contigs_antismash"]
    conda:
        "../../../envs/seqtk.yaml"
    log: "logs/bgcs/filter_contigs_antismash.log"
    shell: 
       "seqtk seq -L {params.length} {input}  > {output} 2> {log}"

rule antismash:
    input:
        # TODO: Decide what is the input here
        #expand("scratch/assembly/megahit/{treatment}/{kmers}/final.contigs.fa",treatment=config["treatment"], kmers=config["assembly-klist"])
        "scratch/annotation/antismash/secondary.contigs.fa"
    output:
        temp("results/annotation/antismash/secondary.contigs.gbk"),
        temp("results/annotation/antismash/secondary.contigs.json")
    params:
        outdir=lambda wildcards, output: os.path.dirname(output[0])
    conda:
        "../../../envs/antismash.yaml"
    log: "logs/bgcs/antismash.log"
    threads: 16
    shell:
        "antismash --cb-general --cb-knownclusters --cb-subclusters --asf --genefinding-tool prodigal-m --output-dir {params.outdir} --cpus {threads} {input}"

rule get_bgcs:
    input:
        "results/annotation/antismash/secondary.contigs.json"
    output:
        temp("scratch/annotation/antismash/bgcs.fasta")
    log: "logs/bgcs/get_bgcs.log"
    conda:
        "../../../envs/orochi-base.yaml"
    script:
        "../../../scripts/antismash_get_bgcs.py"

rule map_reads:
    input:
        bgcs="scratch/annotation/antismash/bgcs.fasta",
        forward=expand("scratch/host_filtering/{sample}_R1.fastq", project=config["project"], sample=config["data"]),
        rev=expand("scratch/host_filtering/{sample}_R2.fastq", project=config["project"], sample=config["data"])
    output:
        "results/annotation/antismash/bgcs.count.txt"
    conda:
        "../../../envs/coverm.yaml"
    log: "logs/annotation/antismash/bgcs.mapping.txt"
    threads: 24
    shell:
        "coverm contig --methods count --mapper minimap2-sr --proper-pairs-only -1 {input.forward} -2 {input.rev} --reference {input.bgcs} --threads {threads} 2> {log} > {output}"

rule bigscape:
    input:
        gbks="results/annotation/antismash/secondary.contigs.gbk"
    params:
        inputdir=lambda wildcards, input: os.path.dirname(str(input)),
        outdir=lambda wildcards, output: os.path.dirname(str(output))
    output:
        "results/annotation/bigscape/index.html"
    conda:
        "../../../envs/bigscape.yaml"
    log: "logs/bgcs/bigscape.log"
    threads: 40
    shell:
        """
        git clone https://git.wur.nl/medema-group/BiG-SCAPE.git
        cd BiG-SCAPE
        wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam33.1/Pfam-A.hmm.gz && gunzip Pfam-A.hmm.gz
        hmmpress Pfam-A.hmm
        python bigscape.py -i ../{params.inputdir} -o ../{params.outdir} -c {threads} --mode glocal --mibig --include_singletons --cores {threads} --mix
        """


"""
if config['big']=='bigslice':
   rule bigslice:
        input: "scratch/annotation/antismash/secondary.contigs.gbk"
        params:
            inputdir="scratch/annotation/antismash"
            outdir="scratch/annotation/{big}"
        output:
        conda:
            "../../../envs/bigslice.yaml"
        log:
        threads:
        shell:
            "download_bigslice_hmmdb"
            "bigslice -i <{params.inputdir}> <{params.outdir}>"

rule rast:
# Uses myRAST batch processor to upload bigscape output (clusters) and gets rast IDs and downloads faa and txt files in batch.

rule prepare_corason:
# Arranges bigscape and rast output into specified input director structure needed for corason.

rule corason:
    input:
    output:
    container:
        "docker://nselem/corason"
    log:
    threads:
    shell:
"""

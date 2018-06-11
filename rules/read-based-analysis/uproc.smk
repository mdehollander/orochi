rule uproc:
    input:
        fasta="{project}/read-based/fraggenescan/{sample}_forward_paired.ffn"
    output:
        kegg="{project}/read-based/uproc/{sample}.uproc.kegg.txt",
        cog="{project}/read-based/uproc/{sample}.uproc.cog.txt",
        pfam="{project}/read-based/uproc/{sample}.uproc.pfam.txt",
    threads: 8
    run:
        shell("/data/tools/uproc/1.2.0/bin/uproc-prot --preds -o {output.kegg} /data/db/uproc/kegg_20140317/ /data/db/uproc/model {input}")
        shell("/data/tools/uproc/1.2.0/bin/uproc-prot --preds -o {output.cog} /data/db/uproc/cog2014/ /data/db/uproc/model {input}")
        shell("/data/tools/uproc/1.2.0/bin/uproc-prot --preds -o {output.pfam} /data/db/uproc/pfam28/ /data/db/uproc/model {input}")

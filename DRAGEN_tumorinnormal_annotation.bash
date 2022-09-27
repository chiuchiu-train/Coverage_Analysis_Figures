#################################################################################
##########TUMOR-NORMAL TiN (TUMOR IN NORMAL) ANALYSIS
##########Tumor normal paired variant calling with TiN allowing for algorithm to account for normal samples contaminated with tumor
#################################################################################
#!/bin/bash
tumor_fastq_list="pairedtumor_fastqtable.csv"
normal_fastq_list="pairednormal_fastqtable.csv"
tumor_samples_list="tumor_samples.txt"
normal_samples_list="normal_samples.txt"
while read -u 3 -r tumor_RGSM && read -u 4 -r normal_RGSM; do
output_dir="${tumor_RGSM}_${normal_RGSM}"
mkdir -p ${output_dir}
dragen -f \
-r /share/carvajal-archive/REFERENCE_DATA/R01_GDC_GATK/dragen \
--tumor-fastq-list ${tumor_fastq_list} \
--tumor-fastq-list-sample-id ${tumor_RGSM} \
--fastq-list ${normal_fastq_list} \
--fastq-list-sample-id ${normal_RGSM} \
--output-directory ${output_dir} \
--output-file-prefix ${tumor_RGSM}_${normal_RGSM} \
--prepend-filename-to-rgid true \
--vc-enable-liquid-tumor-mode true \  ##remove for regular TUMOR-NORMAL analysis
--vc-tin-contam-tolerance 0.2 \ ##remove for regular TUMOR-NORMAL analysis
--enable-variant-caller true \
--vc-enable-orientation-bias-filter true \
--alt-aware true \
--enable-bam-indexing true \
--enable-map-align-output true \
--enable-duplicate-marking true \
--intermediate-results-dir /share/carvajal-archive/tmp \
--read-trimmers quality,adapter \
--trim-min-quality 20 \
--trim-adapter-read1 /share/carvajal-archive/SEQ_DATA/EXOMES/DRAGEN_BLCA_ARSENIC_090821/adapter_read1.fasta \
--trim-adapter-read2 /share/carvajal-archive/SEQ_DATA/EXOMES/DRAGEN_BLCA_ARSENIC_090821/adapter_read2.fasta \
--fastqc-adapter-file /opt/edico/config/adapter_sequences.fasta \
--fastqc-granularity 7 \
--vc-min-tumor-read-qual 20 \
--vc-target-bed /share/carvajal-archive/SEQ_DATA/EXOMES/DRAGEN_BLCA_ARSENIC_090821/target_BED.txt \
--vc-target-bed-padding 100 \
--vc-decoy-contigs NC_007605,hs37d5,chrUn_KN707*v1_decoy,chrUn_JTFH0100*v1_decoy, KN707*.1,JTFH0100*.1,chrEBV,CMV,HBV,HCV*,HIV*,KSHV,HTLV*,MCV,SV40,HPV* \
--vc-enable-phasing true \
--vc-enable-baf true \
--qc-somatic-contam-vcf /opt/edico/config/somatic_sample_cross_contamination_resource_hg38.vcf.gz \
--vc-systematic-noise /share/carvajal-archive/SEQ_DATA/EXOMES/DRAGEN_BLCA_ARSENIC_090821/systematic-noise-baseline-collection-1.0.0/WES_TruSeq_IDT_hg38_v1.0_systematic_noise.bed.gz \
--dbsnp /share/carvajal-archive/SEQ_DATA/EXOMES/DRAGEN_BLCA_ARSENIC_090821/common_all_hg38.vcf \
--vc-enable-af-filter true \
--vc-af-call-threshold  0.05 \
--vc-af-filter-threshold 0.05 \
--enable-variant-annotation=true \
--variant-annotation-data /share/carvajal-archive/SEQ_DATA/EXOMES/DRAGEN_BLCA_ARSENIC_090821/DATA \
--variant-annotation-assembly GRCh38 \
--vc-enable-germline-tagging true \
--germline-tagging-pop-af-threshold 0.0001 \  ##adjust threshold for tagging germline
done 3<${tumor_samples_list} 4<${normal_samples_list}

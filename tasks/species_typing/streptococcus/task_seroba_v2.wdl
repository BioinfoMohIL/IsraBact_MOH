version 1.0

task seroba_v2 {
  input {
    File read1
    File? read2
    String samplename
    String docker = "sangerbentleygroup/seroba:2.0.4"
    Int disk_size = 100
    Int memory = 16
    Int cpu = 8
  }
  command <<<
    # grab version
    seroba version > VERSION

    # database path will need to be changed if/when docker image is updated. 
    seroba runSerotyping /seroba/database/ ~{read1} ~{read2} ~{samplename}

    # check for serotype grouping & contamination flag
    tail -n +2 ~{samplename}/pred.csv | cut -d',' -f2 > SEROTYPE


    # check for detailed serogroup information
    if [ -f ~{samplename}/detailed_serogroup_info.txt ]; then 
      grep "Serotype predicted by ariba" ~{samplename}/detailed_serogroup_info.txt | cut -f2 | sed 's/://' > ARIBA_SEROTYPE
      grep "assembly from ariba" ~{samplename}/detailed_serogroup_info.txt | cut -f2 | sed 's/://' > ARIBA_IDENTITY
    else 
      # if the details do not exist, output blanks to ariba columns
      echo "" > ARIBA_SEROTYPE
      echo "" > ARIBA_IDENTITY
    fi
  >>>

  output {
    String seroba_version = read_string("VERSION")
    String seroba_docker = docker
    String seroba_serotype = read_string("SEROTYPE")
    String? seroba_ariba_serotype = read_string("ARIBA_SEROTYPE")
    String? seroba_ariba_identity = read_string("ARIBA_IDENTITY")
    File? seroba_details = "~{samplename}/detailed_serogroup_info.txt"
  }

  runtime {
    docker: "~{docker}"
    memory: memory + " GB"
    cpu: cpu
    disks: "local-disk " + disk_size + " SSD"
    disk: disk_size + " GB"
    maxRetries: 3  }
}
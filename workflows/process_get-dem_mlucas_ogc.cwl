cwlVersion: v1.2
$graph:
- class: Workflow
  label: get-dem
  doc: This is a wrapper for the sardem-sarsen algorithm to exercise the MAAP processing
    pipeline.
  id: get-dem
  inputs:
    bbox:
      doc: Bounding box as 'LEFT BOTTOM RIGHT TOP'
      label: bounding box
      type: string
    compute:
      doc: Flag to perform intense, multi-core computations (any non-empty value will
        enable this)
      label: compute
      type: string
  outputs:
    out:
      type: Directory
      outputSource: process/outputs_result
  steps:
    process:
      run: '#main'
      in:
        bbox: bbox
        compute: compute
      out:
      - outputs_result
- class: CommandLineTool
  id: main
  requirements:
    DockerRequirement:
      dockerPull: ghcr.io/maap-project/get-dem:mlucas_ogc
    NetworkAccess:
      networkAccess: true
    ResourceRequirement:
      ramMin: 5
      coresMin: 1
      outdirMax: 20
  baseCommand: /app/get-dem/nasa/run.sh
  inputs:
    bbox:
      type: string
      inputBinding:
        position: 1
        prefix: --bbox
    compute:
      type: string
      inputBinding:
        position: 2
        prefix: --compute
  outputs:
    outputs_result:
      outputBinding:
        glob: ./output*
      type: Directory
s:author:
- class: s:Person
  s:name: mlucas
s:contributor:
- class: s:Person
  s:name: mlucas
s:citation: https://github.com/MAAP-Project/get-dem.git
s:codeRepository: https://github.com/MAAP-Project/get-dem.git
s:dateCreated: 2025-03-12
s:license: https://github.com/MAAP-Project/get-dem/blob/develop/LICENSE
s:softwareVersion: 1.0.0
s:version: mlucas/ogc
s:releaseNotes: None
s:keywords: ogc, sar
$namespaces:
  s: https://schema.org/
$schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf

cwlVersion: v1.0
$graph:
- class: Workflow
  label: shah-get-dem-nasa-ogc
  doc: OGC compliant app package for get-dem algorithm
  id: shah-get-dem-nasa-ogc
  inputs:
    bbox_left:
      type: string
      label: bbox_left
      doc: ''
      default: '-118.06817'
    bbox_bottom:
      type: string
      label: bbox_bottom
      doc: ''
      default: '34.22169'
    bbox_right:
      type: string
      label: bbox_right
      doc: ''
      default: '-118.05801'
    bbox_top:
      type: string
      label: bbox_top
      doc: ''
      default: '34.22822'
  outputs:
    output_context:
      type: Directory
      outputSource: process/job_output
  steps:
    process:
      run: '#process'
      in:
        bbox_left: bbox_left
        bbox_bottom: bbox_bottom
        bbox_right: bbox_right
        bbox_top: bbox_top
      out: [job_output]
- class: CommandLineTool
  id: process
  requirements:
    DockerRequirement:
      dockerPull: container-get-dem:nasa-ogc
  baseCommand: /app/get-dem/nasa/run.sh
  arguments: []
  inputs:
    bbox_left:
      type: string
      inputBinding:
        position: 1
        prefix: --bbox_left
    bbox_bottom:
      type: string
      inputBinding:
        position: 2
        prefix: --bbox_bottom
    bbox_right:
      type: string
      inputBinding:
        position: 3
        prefix: --bbox_right
    bbox_top:
      type: string
      inputBinding:
        position: 4
        prefix: --bbox_top
  outputs:
    job_output:
      type: Directory
      outputBinding:
        glob: output*
$namespaces:
  s: https://schema.org/
s:softwareVersion: nasa-ogc
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf

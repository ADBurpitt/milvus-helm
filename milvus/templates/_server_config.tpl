{{- define "milvus.serverConfig" -}}
# Default values are used when you make no changes to the following parameters.
version: 0.1

server_config:
  address: 0.0.0.0                  # milvus server ip address (IPv4)
  port: 19530                       # milvus server port, must in range [1025, 65534]
  deploy_mode: {{ .Values.deployMode }}               # deployment type: single, cluster_readonly, cluster_writable
  time_zone: UTC+8                  # time zone, must be in format: UTC+X

db_config:
  primary_path: {{ .Values.primaryPath }}         # path used to store data and meta
  secondary_path:                   # path used to store data only, split by semicolon

  backend_url: mysql://root:{{ .Values.mysql.mysqlRootPassword }}@{{ .Release.Name }}-mysql:3306/{{ .Values.mysql.mysqlDatabase }}       # URI format: dialect://username:password@host:port/database
                                    # Keep 'dialect://:@:/', and replace other texts with real values
                                    # Replace 'dialect' with 'mysql' or 'sqlite'

  insert_buffer_size: {{ .Values.InsertBufferSize }}             # GB, maximum insert buffer size allowed, must be a positive integer
                                    # sum of insert_buffer_size and cpu_cache_capacity cannot exceed total memory

  preload_table:                    # preload data at startup, '*' means load all tables, empty value means no preload
                                    # you can specify preload tables like this: table1,table2,table3

metric_config:
  enable_monitor: {{ .Values.metrics.enabled }}             # enable monitoring or not, must be a boolean
  collector: prometheus             # prometheus
  prometheus_config:
    port: {{ .Values.metrics.port }}                      # port prometheus uses to fetch metrics, must in range [1025, 65534]

cache_config:
  cpu_cache_capacity: {{ .Values.cpuCacheCapacity }}            # GB, size of CPU memory used for cache, must be a positive integer
  cache_insert_data: {{ .Values.cacheInsertData }}          # whether to load inserted data into cache, must be a boolean

engine_config:
  use_blas_threshold: {{ .Values.useBLASThreshold }}          # if nq <  use_blas_threshold, use SSE, faster with fluctuated response times
                                    # if nq >= use_blas_threshold, use OpenBlas, slower with stable response times
  gpu_search_threshold: {{ .Values.gpuSearchThreshold }}        # threshold beyond which the search computation is executed on GPUs only

gpu_resource_config:
  enable: {{ .Values.gpu.enabled }}  # whether to enable GPU resources
  cache_capacity: {{ .Values.gpu.cacheCapacity }}                 # GB, size of GPU memory per card used for cache, must be a positive integer
  {{- with .Values.gpu.searchResources }}
  search_resources:                 # define the GPU devices used for search computation, must be in format gpux
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.gpu.buildIndexResources }}
  build_index_resources:            # define the GPU devices used for index building, must be in format gpux
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}

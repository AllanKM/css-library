# Categorizes all PDFs/docs in the current directory into CS subject folders.
# Priority-ordered: first matching rule wins. Designed for the tpn/pdfs collection.

param(
    [switch]$DryRun,
    [string]$Trace,
    [switch]$ShowAll
)

$ErrorActionPreference = 'Stop'

# Files we never touch.
$keepAtRoot = @(
    '.gitignore',
    'README.md',
    'organize.ps1',
    'file_list.txt',
    'dir_list.txt',
    'dryrun_output.txt',
    'dryrun_full.txt',
    'move_log.txt'
)

# Priority-ordered rules. First match wins.
# Each rule is @{ Name = '...'; Patterns = @('regex1','regex2',...) }.
$rules = @(
    @{ Name = 'Reverse-Engineering-and-Binary-Analysis'; Patterns = @(
        'reverse engineer','disassembl','decompil','\bIDA Pro\b','Hex-?Rays','HexRays',
        'PECOFF','Portable Executable','\bPE Format\b','\bPE File\b','\bPE Injection\b',
        '\bELF Format\b','\bELF Handling\b','Detours','Reflective DLL','Remote Library Injection',
        'Anti-?Debug','PyEmu','\bPin (Tutorial|Building|Instrumentation)','Vulcan - Binary Transformation',
        'Rewriting x86 Binaries','In-Depth Analysis of Disassembly','Stratified Synthesis',
        'Improving Automated Analysis of Windows','Reverse-Engineering Instruction Encodings',
        'Name Mangling','Kam1n0','HexRaysCodeXplorer','MARX - Uncovering','Symbol(ic Execu| table)',
        'Crash Dump Analysis','Pool Tag','Stratified Synthesis','PE Format Walkthrough','Peering Inside the PE',
        'Undocumented PECOFF','Things You Didn''t Know.*PE','PE Format Layout','Standard Annotation Language',
        'jargon file','jargn10','Proof of Concept or GTFO','x86asm','ObCaptureObjectName','Objconv',
        'Fingerprinting','Driver Annotations','MSDN Journal'
    )},
    @{ Name = 'Cryptography-and-Security'; Patterns = @(
        '\bAES\b','Advanced Encryption Standard','Galois Field','SHA-?3','\bSkein\b','BLAKE2','Keccak',
        'TrueCrypt','\bBitcoin\b','Hashcash','SipHash','Cryptograph','encryption','\bcipher\b',
        'cryptanaly','Spectre','Meltdown','Flush\+Reload','\bFallout\b - Reading Kernel','side[- ]channel',
        'ASLR','\bROP\b','Return-Oriented','Shadow Stack','Control Flow Guard','SafeSEH','Heap Spray',
        'exploit','vulnerab','\battack(s|ing)?\b','malware','privilege escalation','Kernel Pool Exploit',
        'Bypass Control Flow','Captain Hook - Pirat','Black Hat','BlackHat','SSTIC','BSDCan','syscan',
        'Stack Exploit','Penetration','Computer Forensic','Memory Forensic','Logon Forensic','UEFI Landscape','Hyper-V Architecture and Vulner',
        'KASLR','Jump Over ASLR','Branch Mispredictions','Meltdown','Spectre','Transient Execution',
        'Pool Party','Scoop the Windows','Ring 0 to Ring','Misomorphism','Programming Satan','Security Engineering',
        'Trust','Crypto Audit','TLB Invalidation','True IOMMU','Open Crypto','SEH Exploit',
        'Kernel Attacks','Estoteric Hooks','Kernel Notification Routines','I Got 99 Problems But a Kernel Pointer',
        'KQguard','Captain Hook','Pirating AVs','Logon Forensics','WMI.*Offense'
    )},
    @{ Name = 'AI-and-Machine-Learning'; Patterns = @(
        'neural network','neural net','deep learning','machine learning','reinforcement learning',
        '\bLLM\b','\bGPT[- ]','language model','\bLLama\b','DeepSeek','AlphaFold','AlphaGo',
        'transformer','\bBERT\b','attention is all','FlashAttention','Mamba','RWKV','RoFormer','GateLoop',
        'KV Cache','KIVI','KVQuant','REFRAG','SuffixDecoding','Toolformer','Titans','Megatron',
        'Word(2|-)Vec','Word Embedding','Word Representation','word vector','Retrofitting Word',
        'recurrent neural','\bRNN\b','convolutional','ResNet','ImageNet','Image Recognition',
        'YOLO','Image Classif','Image Restoration','Noise2Noise','Dropout','Batch Normaliz','Layer Norm',
        'gradient descent','gradient boost','XGBoost','AdaBoost','LightGBM','FastBDT','Stable-Baselines',
        'softmax','GELU','Adam.*Stochastic','Statistical Learning','Probabilistic.*Deep','Bayesian',
        'Monte[- ]Carlo','Hidden Markov','Speech Recognition','Sequence to Sequence','Neural Machine Translation',
        'Distilling.*Knowledge','Adversarial','Generative.*Pre-Train','Pre-training','Few-Shot Learner',
        'Unsupervised Multitask','Random Network Distillation','Tensor Product Attention','Kolmogorov-Arnold',
        'Knowledge Distillation','Stochastic Gradient','Back-Propag','Backprop','Perceptron',
        'Word.*Embeddings','Embeddings\b','Recommender','Collaborative Filter','Item-Based Collaborative',
        'AutoML','Hyperparameter','Hyperopt','Allure of Machine Learning','MMLSpark','TensorFlow',
        'CNTK','Computational Network','\bSLIDE -','Probabilistic Programming','Self-Supervised Learning',
        'Universal Approximation','LeCun','LSTM','Long Short-Term',
        'Conv(olutional|Net)','Document Recognition','Topic-Biased PageRank',
        'Dijkstra''s in Disguise','Dueling Network','Dota 2','Game of Go',
        'NeuralSVG','Neural Radiance','Instant Neural','Universal Geometry of Embeddings',
        'LumberChunker','Train(ing)? Language Model','Prompt Engineer','OpenAI','GPT-4',
        'Highly accurate protein','Eric Jang','Google.*Translation','TelaMalloc','RTop-K',
        'AzureML','Azure ML','Resurrecting Recurrent','Support Vector','Logistic Regress',
        'Stochastic Optim','Hyperparameter Optim','Hidden Markov Model','MMLSpark','TensorFlow',
        'AlphaFold','Mastering the Game','Chess','Goban','BERT','GAN\b','Diffusion Model',
        'Variational Autoencoder','RLHF','SFT\b','RLAIF','PPO','DDPG','TD3\b','SAC\b',
        'Federated Learning','Active Learning','Few-Shot','Zero-Shot','Meta-Learning',
        'Allure of Machine','Foundation Model','Multimodal','Multi-modal','Diffusion','Audio Recognition',
        'Convolutional|Conv-Net|ConvNet|CNN\b','Vision Transformer','VAE\b','PaLM\b',
        'Function of Dream Sleep','Attention is All','Pretrain',
        'Training LLMs','Finding Structure in Time','Fundamentals of Learning','Kalman Filter',
        'Top.*LLM Interview','DNA Sequence','Genome'
    )},
    @{ Name = 'GPU-and-Graphics'; Patterns = @(
        '\bCUDA\b','\bGPU\b','GPGPU','OpenGL','OpenCL','GLSL','Vulkan','DirectX','Direct3D',
        'NVIDIA','\bNvidia\b','GeForce','Tesla (K|V|P|A|H|T)','\bVolta\b','\bTuring\b','\bAmpere\b',
        '\bHopper\b','Blackwell','Tensor Core','Fermi Compute','Pascal',' Kepler\b','Kepler ',
        'Graphics Pipeline','ray trac','Ray Pack','\bshader\b','BRDF','Reyes','Rendering','Rasteriz',
        'Geometry Engine','Vertex Process','Pixel Process','Compute Shader','Tessellation',
        'Texture Sampler','BitBlt','Bitmap Graphics','Bitmap Graphs','SIGGRAPH','Bounds Checking on the GPU',
        'GPU(Direct| Random| Control| Optimization| Programming| Hash)','HIP\b','\bThrust\b','Brook for GPU',
        'Gunrock','\bispc\b','iBFS','GraphBLAS','Free Launch','Heterogeneous','\bDGX-1\b','DGX',
        'cuDF','cuFile','Numba','Pythran','Thrust','PyCUDA','GTX 1080','GTX 980','A100','H100',
        'Latency Hiding on GPU','Demystifying GPU','Dissecting the NVIDIA','GeForce','GPUDriver',
        'Hash Functions for GPU Rendering','Cooperative Kernels','Cooperative Groups','Optimizing Parallel Reduction',
        'Warp Shuffle','Warp Reduction','Reductions on GPU','GPU(\s|-)?Sort','GPU(\s|-)?Hash',
        'CS195V','RAPIDS','Microbenchmarking','How Does a GPU Shader','HARE - Hardware Acceleration for Regular',
        'Tensor Cores','Triton.*Tiled Neural','LightScan','Trip Through The Graphics','Achieving Full-Motion Video',
        'Microsoft Research.*Visual','Image Sampler','Cushion Treemap','Squarified Treemap','Treemap',
        'Choosing a Good Chart','Misuse of Colour','Visualization','Treemaps','PixelProces','Stereoscopic',
        'IO and 3D Graphics','Sega Saturn','Playstation','PS4 Toolchain','GDC ','Half-Precision Matrix',
        'BMP|PPM Format','Image File Format','M4 - A Visualization','PaohVis','Hypergraphx','HyperNetX',
        'Dynamic Hypergraphs','Visualizing.*Graph','Overplotting','Abstract Rendering','InK-Compact',
        'KLAP - Kernel Launch','GTC 20','Tesla[ -]','Reyes','Rolling Sphere','Nintendo','SPMD',
        'Introduction to GPUs','Joins to a Thousand GPUs','GPU(\\b|s\\b)','Multi-GPU','PyCUDA',
        'CUPER','GPGPU','Generalized Histogram','Parallel Hashing on the GPU','State Space Exploration.*GPU'
    )},
    @{ Name = 'Concurrency-and-Parallelism'; Patterns = @(
        'lock-?free','wait-?free','non-?blocking','Memory Consistency','Memory Barrier','Memory Order',
        'Transactional Memory','\bRCU\b','Read-Copy-Update','Hazard Pointer','Compare-and-Swap','Compare and Swap',
        'Atomic','Synchronization','Synchroniz','Spinlock','Spin-?Lock','Mutex','Semaphore','Condition Variable',
        '\bDeadlock\b','Concurren','Parallel(ism|izing|ization|ize)','Multithread','Multi-?core','Many-?core',
        'Thread (Synchron|Context|Basics|Tutorial|Sched|Local)','Threading Building Blocks','OpenMP',
        'Disruptor','Epoch[- ]Based','Memory Reclamation','Scalable.*Multi','Linux Kernel Lock','Per-CPU',
        'Race Condition','Data Race','Hardware Lock Elision','TSX','Hardware Transactional','Adding Lock Elision',
        'Compiler.*Vector(ize|ization)','Vectorization','\bSIMD\b','\bSSE\b','\bAVX\b','\bMMX\b','SWAR',
        'Reentrant','TLS','ELF Handling for Thread','Thread-?Local','Concurrent Hash','Concurrent Garbage',
        'Garbage Collection','\bGC\b','Reference Count','RefCount','Counting','Down For The Count',
        'Compare-And-Swap','Lockless','Reader-Writer','Producer-Consumer','Producer Consumer','Reduction',
        'Real World Concurrency','Real-Time Concurrency','Synchroniz.*Primitives','Futex','Pinned',
        'Saturated','Queue.*Concurrent','Bounded Queue','SALSA','MegaPipe','SPMD','PySymemu','Affinity',
        '12 Commandments of Synchroniz','Memory Barriers','Synchrobench','Wait-Free','Lock Free',
        'Speculative Parallelism','Amplab','Dynamic Parallelism','Async','Asynchron','Coroutine',
        'Self-Allocating Threads','Lonestar','Parallel Computation','Parallel Irregular',
        'Wegner Transactive','Parallel Programming','Parallel Random','Parallel Prefix','Parallel Scan',
        'Parallel Hashing','Parallel Lossless','Parallel Sort','Parallel Depth','Parallelism in Random',
        'Virtual Threads','Featherweight Threads',
        'Reactor.*Object','Proactor','Resumable Function','Fibers','Coq.*Macro Assembler','Tracing JIT',
        'Pony','Pony lang','Ponylang','CAF.*Actor','Actor World','Erlang','Grand Central Dispatch',
        'Global Interpreter Lock','\bGIL\b','PyParallel','QuickThread','Threading.*Comparison',
        'Eliminating.*GIL','Async\s+IO','Asynchronous IO','Lazy Asynchronous IO','asynchronous, zero-copy',
        'Disruptor','Spin-Based Reader','Preemptable Ticket','Wake-up Latencies','Idle Connection',
        'Self-stabiliz','Distributed Mutual','PlusCal','TLA\+','Petri Net'
    )},
    @{ Name = 'Distributed-Systems'; Patterns = @(
        'Distributed System','Distributed Comput','Distributed Sim','Distributed Trac','Distributed Comp',
        'Distributed Job','Replicat','\bChord\b','\bRaft\b','\bPaxos\b','Consensus','CRDT','Convergent and Commutative',
        'Tango','CORFU','Dapper','Canopy','SEDA','Map(?:R|-?)educe','Hadoop','Spark','HDFS','BigQuery',
        'Microservice','Cloud','Datacenter','Data Center','Time, Clocks','Lamport.*Distributed',
        'Failure-Atomic','Aria','Byzantine','Two-Phase','Three-Phase','Paxos','Distributed Hash Table',
        'Peer-to-Peer','Gossip','Anti-?Entropy','Eventual','Vector Clock','Tracing Infrastructure',
        'Linearizab','Leader Election','State Machine Replic','MemCach','Multi-Paxos','Causal Profil',
        'Ownership.*Distributed','Distributed Future','Ray v2','Snapshot Isolation','Self-stabilizing',
        'Survey of Rollback','SimNet','Apache Parquet','MQTT','Dataflow Model','ZeroMQ','Nobody.*Hadoop',
        'Linear Road','Trill','Ten Years with DragonFlyBSD Network','HyperANF',
        'Distributed Time Series','BGP','Service Mesh','Pregel','Blogel','Gunrock'
    )},
    @{ Name = 'Databases'; Patterns = @(
        'database','\bDBMS\b','\bRDBMS\b','SQL','PL/?SQL','PLSQL','MySQL','PostgreSQL','SQLite','Postgres',
        'Oracle','DB2','MonetDB','Vertica','Cassandra','Tokutek','TokuDB','Snel','Comdb2','BigQuery',
        '\bB\+?-?Tree','B\+ Tree','BTree','Bw-?Tree','LSM','LSM-?Tree','Fractal Tree','Tries\b',
        'Trie\b','Trie Memtable','HAT-trie','Patricia Trie','TPC-H','TPC-C','OLAP','OLTP','Star Schema',
        'Bitmap Index','Inverted Index','Index Compression','Query Process','Query Plan','Query Optim',
        'Query Engine','Window Function','SIMD-Friendly','Columnar','Column-?Store','C-Store','In-Memory.*Database',
        'Main[- ]?Memory.*Database','Database Sys','Recovery','ARIES','Write-Ahead','WAL','Catalog',
        'Roaring','Bloom Filter','Cuckoo Filter',
        'Hash Join','Hash Probe','Adaptive Hash','Hash Index','Bitmap Index','Inverted Index',
        'Record Linkage','RecordLinkage','BigDataBench','Range Quer','Reachability Quer','Query.*Graph',
        'Graph Database','Property Graph','SQLGraph','MISTRAL.*Multidimensional','Stream Data Manag',
        'Streaming Aggreg','Sliding Window','Frequent Items','Stream.*Cardinality','Quantile.*Stream',
        'Heavy Hitter','Time Series','Motif','Anomaly Detection','Storm.*OneShot','Track Join',
        'Window Aggreg','Cardinality','Join Algorithm','Join.*Network','Repeating History.*ARIES',
        'Apache Parquet','Vertica','Trill','Linear Road','Linear ?Road','PostgreSQL','PLPython',
        'Codd','Relational Model','In-Memory Search','Derivability.*Relations','MySQL','Adaptive Query',
        'Predicate Transfer','MapReduce','Dataflow','Dataframe','Pandas\b','SciPy','NumPy','SQL Native',
        'OneShotSTL','VLDB ','SIGMOD','ICDE',
        'DataMining-','Data Mining','Index Internals','NYSE OpenBook','Apache Parquet','Quasi-Succinct',
        'Inverted','Index ','Index\b','Star Schema','Bitmap Indic','Bitmap Index','Star Tran','Adaptive Index',
        'Sorted-Set','Repeating History','In-Memory Database','BigDataBench','Bloomberg.*Highly Available',
        'Bloomberg','Comdb2','Sortledon','Reachability','SQLGraph','Property Graph','MISTRAL.*Multi'
    )},
    @{ Name = 'Algorithms-and-Data-Structures'; Patterns = @(
        '\bsort\b','sorting','Quicksort','Quick Sort','Merge Sort','Radix Sort','Bitonic','Counting Sort',
        'Selection Sort','Insertion Sort','Comparator','Sort.*Algorithm','sort algorithm','Sort-Merge',
        'Hash(?:ing|table)','Hashing','Universal Hash','SipHash','MurmurHash','CityHash','Rolling Hash',
        'Hash Table','Hash Function','Perfect Hash','Minimal Perfect','Locality.?Sensitive Hash',
        'SicHash','RecSplit','GPERF','Dynamic Perfect','Hash Indicat','Hash and Displace',
        'Cuckoo Hash','Cuckoo Table','Quotient Filter','ShockHash','IcebergHT','WarpCore','HASHI',
        'Skip List','SkipList','Skiplist','Storing a Sparse Table','Suffix Tree','Suffix Array',
        'Suffix Tries','FM-Index','Burrows-?Wheeler','\bBWT\b','Wavelet Tree','Compressed Suffix',
        'Pattern Match','Aho-Corasick','Prefix Code','Prefix Tree','Prefix Hash','Prefix Sum','Prefix Search',
        '\bLCE\b','Levenshtein','Edit Distance','String Match','Bitmap','Compressed Bitmap',
        '\bgraph\b','Hypergraph','DAG','Acyclic Graph','BFS','DFS','depth-first','breadth-first',
        'Cycle Pack','Hamilton','Dijkstra','Tarjan','Closest-Pair','Shortest Path','Spanning Tree',
        'Pattern Match','Random Graph','Random.*Hypergraph','Coloring','Color\b','Planar','Vertex',
        'algorithm','data structure','Skiplist','Skip List','Linked List','Splay Tree','AVL Tree',
        'Heap\b','Priority Queue','Stack Algorithm','Queue Algorithm','Bloom','Cuckoo','Quotient',
        'Compress.*Suffix','HyperLogLog','Sliding Window','Min(imum|imal)? Hash','MinHash',
        'Counting Bloom','Approx.*Member','Fast.*Search','Fast Prefix','Fast.*String','String Match',
        'Two-Way String','Substring Search','Aho-?Corasick','Ukkonen','Boyer-Moore','Z-Algorithm',
        'Knuth.*Morris','Combinator','Probabilistic Data','Sketch','Bitmap','Computational Geometry',
        'Geomet','Convex Hull','Convex Optimization','Closest Pair','Folding','Erik.*Demaine',
        '\bk-Ary\b','Binary Search','Tree Search','Binary Tree','Bowstring','Probabilistic Counting',
        'Topic Indexing','Cardinality Estimation','Reservoir Sampling','Approximate.*Sample',
        'Pseudo-?Random','Random Number','RNG','PRNG','Marsaglia','Xorshift','TestU01','Splittable',
        'Encoding\b','Decoder','Coding (Theor|of|Method|Scheme)','Huffman','Arithmetic Coding',
        'Golomb','Elias','Unary Coding','Universal Code','Wavelet Tree','Range Min','Range Coding',
        'rank.*select','Succinct','Quasi-Succinct','Self-Index','Persistent Data','Versioned',
        'Retroactive','Self-Adjust','Optim.*Algorith','Approximation','Probabilistic Theor','Roar',
        'Compressed Bitmap','Roaring Bitmap','SAT Solver','SMT.*Solver','Z3','Witnesses for','Combinatorial',
        '3-SAT','3CNF','Game Tree','Hyperedge','Hyperloglog','Optimization (Theor|Problem|with Expone)',
        'Linear Probing','Open Address','LinkedList','Tree Indexing','Inverted','Rank-Select',
        'Cone','Faster Cutting',        'Mihai','Bumper Sticker','Lower Bound.*Data','Tight Cell-Probe',
        'Folding and Unfolding','Notorious Four-Color','Dijkstra',
        'HyperLogLog','TinyLFU','PageRank','TruRank','BM25','Information Retrieval',
        'Cardinality Estimation','Markov Chain','Outlier Detection','Streaming Data Mining',
        'Item-Based Collaborative','Recommender','Collaborative Filter',
        'HyperANF','Page Rank','LSM-trie','SmartIndex','Bayesian Reasoning','Bayesian Data',
        'Bayesian Optim','Markov Model','Hidden Markov\b',
        'Array Layouts','Broadword','Deterministic Selection','Random Sampling','Sampling.*Algorithm',
        'Finding Similar Items','Finding Small Balanced','Hash Tree','Acyclic Finite State',
        'Finite Automata','Sum of Degrees of Vertices','Longest Common Extension','Perfect Matching',
        'Rainbow matching','Hamilton Cycle','Edge-Isoperim','de Bruijn-Newman','Closest-Pair','Closest Pair',
        'Maintaining Knowledge.*Temporal','Temporal Interval','Allen.*Interval Algebra','Constraint Propagation',
        'Twenty-Five Comparator','Sorting (Nine|Ten|Network)','Apache Spark','MapReduce','SAT Solver',
        'Empirical Study.*SAT','Witnesses for Non-Satisfiab','Finding Frequent Items','Sliding-Window'
    )},
    @{ Name = 'Compression-and-Information-Theory'; Patterns = @(
        '\bcompression\b','compress','Decompress','Lossless','Lossy','Block-sorting','Entropy',
        'Huffman','Arithmetic Coding','LZ77','LZ78','LZ4','Snappy','zstd','zlib','gzip','Deflate',
        'Burrows-?Wheeler','BWT','Run-Length','Mathematical Theory of Communication','Shannon',
        'Information Theory','Mutual Information','CRC\b','Redundancy','Source Coding','Channel Coding',
        'Bit Compress','Wavelet Compress','Index Compress','Database.*Compress','Indices Compress',
        'Bitmap.*Compress','Roaring','Tunable Compression','Adaptive String Dict','Lightweight Compression',
        'Encoding.*Image','Adaptive Coding','BLAS Kalkulator',
        'Binary Coding','Codes for Positive Integers','Integer Encoding','Integer Code','Spread Unary',
        'Unary Encoding','Unary Coding','Unary Negation','Variable Length','Prefix-Free','Prefix Free',
        'Wavelet Compress','Image and Video.*Encoding','Shannon','Entropy Coding','Coding (Theor|of|Method|Scheme)',
        'Lossless Source','Compression on Graphics','Database Compress','Lightweight Compress','Compressed.*Pointer',
        'Compress.*Bitmap','File Comparison Program','Bit Operations'
    )},
    @{ Name = 'Compilers-and-Programming-Languages'; Patterns = @(
        '\bcompiler\b','compilation','Codegen','Code Gen','intermediate language','interpret','\bJIT\b',
        'Programming Language',
        '\bAST\b','parser','parsing','syntax','semantics','type system','type check','formal semantics',
        'lambda calc','garbage collect','LLVM','Clang','GCC','MSVC','Roslyn','Cython','PyPy','RPython',
        'Trace.*JIT','Tracing JIT','Probabilistic Programming','Z3','PlusCal','TLA','K Framework','K Semantic',
        'Coq','Haskell','Scala','\bRust\b','\bGo\b ','Erlang','Pony','Clojure','Lisp','Scheme','OCaml',
        'F[#]','C\+\+','C Programming','C99','C11','C17','C18','C20','C2x','C23','Modern C','Java\b',
        'JavaScript','ECMA','TypeScript','\bRuby\b','Python','PEP\b','Pandas','NumPy','SciPy','R Package',
        'PL/SQL','PL/I','JOVIAL','AWK','Perl','PHP','Bash','PowerShell','Solidity','Forth','Modula',
        'Pascal','Algol','Fortran','MATLAB','Octave','Julia','Object-Oriented','Algebraic Effect',
        'Sequent Calculus','Build System','Static Analysis','Static Driver','Symbolic Execution',
        'Program Analysis','Pointer Analysis','Sketching','Program Synth','Inline Function',
        'Call Stack','Calling Convention','Name Mangling','Stack Unwind','Exception Handling',
        'Inline Asm','PySymemu','Inline Function Expansion','SAT Solver','SMT Solver','Solver',
        'Verification','Model Check','Refactor','Coccinelle','Semantic Patch','Coverity','Bug',
        'Detecting.*Errors','C# ','Visual Studio','MSBuild','GraalVM','SBCL','MIPSpro','Tru64','VAX',
        'OpenVMS RTL','Gazing.*Reflection','CppCon','Boost','Foreign Library','DTrace','strace','GDB',
        'Continuation','Coroutine','Resumable Function','Algebraic Effects','Build Systems a la Carte',
        'Out of the Tar Pit','Death of Optimizing','Real Programming','LISP','Structured Programming',
        'Niklaus Wirth','Foreign Library','Vectorization','C\+\+ vector','Python Compiler','Compiler Design',
        'Trace-based Just-in-Time','Specialising Dynamic','37 Million Compilations','C\+\+ Memory Model',
        'Resumable Functions','Joint Strike Fighter.*C\+\+','Cluster of Lights','Allocation Removal',
        'C\+\+14','C\+\+17','C\+\+20','PEP ','Modern C v2','K - A Rewriting','Computer Theory',
        'Satisfiability Modulo','Development of.*Language','Practical R\b','R Inferno','Building R Packag',
        'Creating R Packages','Writing R Extensions','Learning Statistics with R','AddressSanitizer',
        '\bKLEE\b','Pointer Analysis','Memory Safety for Programs','Termination and Memory',
        'Analyzing Runtime and Size','SAT and SMT','SMT and Z3','Logic and Comput','Lambda Calculus',
        'Symbolic Execution','Static Analysis','Static Driver','Coverity','Formal Verification',
        'Verification of the','Verification Techn','Self-Verifying','Symbolic Unit','Probabilistic Theory of Deep',
        'Working Draft','C\+\+ Standard','C\+\+11','Bringing SIMD','Sequence Modeling','Solidifying.*SMT',
        'Atomic Block','Boehm','Memory Model','Algol','SPARK','Kerncraft','Reasoning about Temporal',
        'Compile-time','Type Specialization','Just-in-Time Static','Lonestar','Build Systems',
        'Niklaus Wirth','Compiler Confidential','Pythran','Cython','Numba','Bottom Up','Sequent Calculus',
        'Lazy and Speculative','Trace-based','Notes on','Introspection for C','Library Robustness'
    )},
    @{ Name = 'Computer-Architecture'; Patterns = @(
        'Intel 64','Intel Architecture','Intel Xeon','Pentium','\bIntel\b','AMD64','\bAMD\b','Athlon',
        'Opteron','AMD Family','VIA CPUs','Microarchitecture','Instruction (Set|Tab)','ISA Reference',
        'Instruction Encoding','Instruction Tables','Calling Convention','Software Optimization Guide',
        'Optimization Reference Manual','BIOS and Kernel Developer','BIOS Developer','ACPI','PCI Express',
        '\bTLB\b','\bcache\b','CPU Cache','Branch Pred','Speculation','Speculative Exec','Microcode',
        '\bCPU\b','Processor','CPUID','x87','Float(ing)? Point','\bFPU\b','\bSIMD\b','\bSSE\b','\bAVX\b','\bMMX\b','\bVEX\b','\bEVEX\b',
        '\bx86\b','\bx64\b','IA-32','IA-64','Itanium','SPARC','POWER','\bMIPS\b','RISC-V','Alpha AXP',
        'Alpha NT','VAX','PDP-?11','\bARM\b','AArch64','Cortex','Hyper-Threading','Hyperthread','NUMA',
        'Cache Coherence','Cache Allocation','Cache Performance','Cache Pollution','Cache Optim',
        'Memory Hierarch','Bit Manipulation','Bit Shift','Bit Permut','Bit Gather','Bit Scatter',
        'Carry-?Less','PCLMUL','CRC Computation','Population Count','Popcount','Hardware Counter',
        'Performance Counter','Hardware Performance','Microbench','Benchmark.*Code','Cores That Don',
        'Two''s Complement','Itanium','Hyper-V','Virtualization','Hypervisor','Singularity','5-Level Paging',
        'Mach.*Kernel Foundation','Computer System Design','Datacenter as a Computer',
        'PCI-e','PCIe','PCI ','SMBIOS','PMU','Performance Monitoring',
        'Process Trace','Branch Predictor','Memory Consistency','Modern Microprocessors','New Basis for Shifters',
        'Hardware Acceleration','Parallel Architectures','Plat.*Architecture','Stack-based Microarchitec',
        'Asim','VLIW','SystolicArray','Systolic','OpenSPARC','Knights Landing','MIC Architecture','Xeon Phi',
        'AMD GPU','Optane','NVDIMM','CXL','Compute Express Link','PMEM','Persistent Memory','OpenCAPI',
        'Wake-up Latencies','Stride Prefetch','Direct Cache Access','Geo-Distributed','Loongson',
        'Recollections','Original Microsoft Source','Power8','PCIe Systems',
        'AsmDB','Front-End Stalls','Haswell','Memory Prefetcher','Instruction Matrix','Hardware is the new',
        'History of Modern.*64','Recollections.*Chip','Reverse-Engineering Instruction','Encyclopedia of Controller',
        'Modern CPU','Branch Pred','Pin Tutor','Pin -','Cache.*Architecture','Haswell Block','Itanium',
        'TLB','Geometry Engine','Hyper-Threading','Cache Aware Bi-tier','VAX-VMS Internals'
    )},
    @{ Name = 'Memory-Management'; Patterns = @(
        '\bmalloc\b','jemalloc','Hoard','tcmalloc','allocator','Memory Allocator','Custom Memory Alloc',
        'Heap Manag','Heap Allocator','Slab Alloc','Magazines and Vmem','Garbage Collect','\bGC\b',
        'Reference Count','RefCount','Pool Manag','Memory Pool','Object Pool','Arena Alloc',
        'Page Cache','Virtual Memory','Memory Map','msync','Page Manag','Persistent Memory','NVM',
        'Storage Allocation','Memory Reclam','RCU','Read-Copy-Update','Hazard Pointer','Epoch-based',
        'Memory Barrier','Memory Order','Memory Consistency','Memory Profile','Heapy','Python.*Memory',
        'BibBlt','Page Frame','Address Space','Multiple Virtual Address','RadixVM','Big Memory',
        'segment heap','Pool Tag','Allocator.*Multithreaded','Memory Reclamation','MTM','MMU',
        'TelaMalloc','User Mode Memory Page','Hardware Acceleration for Memory','Reference Counting',
        'Improving Python.*Memory','Reconsidering Custom Memory',
        'automemcpy','Reading from External Memory','Non-Volatile Memory','Persistence Programming',
        'Programming Interface.*NVM','Programming Interface.*Memory',        'Indirect Memory Prefetcher',
        'Persistent Memory','What Every Programmer Should Know About Memory','When Prefetching'
    )},
    @{ Name = 'Storage-and-File-Systems'; Patterns = @(
        'File System','filesystem','\bNTFS\b','\bZFS\b','\bAPFS\b','HFS\+?','ext[234]','XFS','UFS','Btrfs',
        'BeFS','Be Filesystem','ReFS','FAT32','EXFAT','SMB','CIFS','NFS','Samba','iSCSI','NVMe','SSD',
        'Hard Disk','Disk Subsystem','Block IO','io_uring','epoll','kqueue','Solid State','Fast Storage',
        'Storage System','Storage Engine','Storage Errors','Storage Setup','Fibre Channel','SAN ',
        'RAID','HDF5','LSM','Log-Structured','Flash','Persistent Storage','Storage Performance','SCSI',
        'WekaFS','OpenVMS','VAX-VMS','Practical File System','Daha','Digital FX32','PCI Express SSD',
        'NVMe Storage','Storage Configuration','Multipath','msync','Failure-Atomic','IRON File',
        'durable','LSM-trie','TPC-H',
        'A File is Not a File','IO Behavior','Statis - Flexible','Transactional Storage'
    )},
    @{ Name = 'Networking'; Patterns = @(
        'Network Stack','TCP/IP','TCP Fast','HTTP','SPDY','HTTP/2','HTTP/3','\bQUIC\b','HTTP Server','100G Network',
        '10Gb','40Gb','100Gb','Ethernet Controller','Ethernet Adapter',
        'Routing','BGP','DNS','RDMA','InfiniBand','Ethernet','100G','10Gb','40Gb','TLS\b',
        'Packet','Network Driver','Network IO','Network Connection','Network Service','Networked',
        'DPDK','Netdev','Open vSwitch','TLS Optim','Affinity Accept','RoCE','iSCSI','NVMe-oF',
        'TSN','Time-Sensitive Network','SDN','OpenFlow','Link Aggreg','SCTP','SOCK_REUS','Web Server',
        'Connection Locality','MegaPipe','SEDA','Lazy Asynchronous','Asynchronous IO','Direct Cache Access',
        'IO Acceleration','IO Completion','IOCP','RPC','DCOM','Component Object Model',
        'Apache','nginx','H2O','Curl','Internet','Narrow Waist','Web Service','Network Connection',
        'Bitcoin','Peer-to-Peer','Proxy','Load Balanc','Join-Idle-Queue','Scal.*Network','Web Architecture',
        'Concurrent Programming for Scalable','RFB Protocol','VNC','RDP','Idle Connection',
        'TCP\b','UDP\b','SCTP','Throughput','Packet Filter','Berkeley Packet Filter','BPF\b','eBPF',
        'Mellanox','NIC ','SMB ','SDN','Spirent','TLS for High','Direct Cache Access',
        'Managing Traffic','ALTQ'
    )},
    @{ Name = 'Performance-and-Optimization'; Patterns = @(
        'Optimiz','Optimisation','Performance','Profiling','Profil','Tracing','Benchmark','Latency',
        'Throughput','Tuning','Speedup','SIMD','AVX','SSE','MMX','Vector(ize|ization)','Vectoriz',
        'Cache-Aware','Cache-Friendly','Cache-Conscious','Cache Efficient','Loop','LoopVect',
        'Parallel.*Performance','How To.*Fast','How Not To Measure','Causal Profil','Coz\b','Heracles',
        'Dataplane','PMU','Performance Counter','Hardware Performance','Cycle Count','SLO',
        'Hot Path','Slow Path','Microbench','Branchless','Optimizing Software','DTrace','perf ',
        'Function Call Trac','Trace-based','Cores That Don','Asim - A Performance','How fast can we',
        'Compile.*Fast','Compile.*Speed','37 Million','Inline Function Expansion','Establishing.*Trust',
        'Highway - Intro'
    )},
    @{ Name = 'Operating-Systems'; Patterns = @(
        '\bkernel\b','Operating System','OS Architect','OS Design','Linux','Solaris','FreeBSD','OpenBSD',
        'NetBSD','DragonFlyBSD','BSD\b','Mach\b','Mach-O','Mac OS','macOS','OSX','Darwin','BeOS',
        'Plan 9','Plan9','Singularity','ReactOS','Minix','Hurd','UNIX','Haiku','SunOS','Solaris',
        'Mach Kernel','Microkernel','Monolithic','Exokernel','Multikernel','Synchronization Primitives',
        'Locking','POSIX','SystemTap','Filter Manag','Filesystem Driver','Driver','Device Driver',
        'Init System','systemd','launchd','Mach IPC','Boot ','BIOS','UEFI','EFI','GRUB','Bootloader',
        '\bNT\s+(Insider|Server|Kernel)','Windows NT','MS-DOS','OS/2','OpenVMS','VAX-VMS','Tru64','HP-UX','AIX','IRIX','Solaris',
        'Process Manag','Scheduler','Schedul','Virtual Memory','Pagetable','Page Fault','User Space',
        'Kernel Mode','User Mode','SystemCall','Syscall','Fork','Exec','Signal','Pthread','Process',
        'IPC ','Shared Memory','Pipe(s)?','Message Queue','Socket','Mutex','Spinlock','Mach API',
        'Mach Message','OS Kernel','UNIX Programming','Mach IPC','Mach Boot','xv6','MINIX','Build.*Operating Sys',
        'Writing.*Operating System','Toy Kernel','Kernel Foundation','Why Aren''t Operating Systems',
        '539Kernel','Mac/UNIX'
    )},
    @{ Name = 'Windows-Internals'; Patterns = @(
        'Windows ','WinDbg','Windbg','Windows Kernel','Windows User','Windows Driver','Windows NT',
        'Windows 10','Windows 8','Windows 7','Windows Vista','Windows XP','Windows Server','Windows Filter',
        'Windows Logon','Windows Pers','Windows New','Windows Network','Windows Privilege','Windows Research',
        'Windows Memory','Windows Software','Windows RPC','Windows Assembly','Windows Heap','Windows Internals',
        'Windows User-?Mode','Windows Persist','Windows Time','Windows Command','Windows Error','Windows Exception',
        'Windows Filter Manager','Windows Name','Windows Privile','Windows Pool','Windows Kernel Notification',
        'NT Kernel','NT Insider','NT Registry','NT Pagefile','NT Server','NTFS','NTFS System','NTFS Document',
        'Microsoft Windows','MSDN','Hyper-V','WMI ','WMI -','Filter Manager - Windows','Detours','MFC',
        'IO Completion','IOCP','Inside IO Comp','Inside IOCP','LPC ','ALPC','Local Procedure Call',
        '\bWin32\b','\bWin64\b','\bPEB\b','\bTEB\b','\bSEH\b','Vectored Exception','\bVEH\b','User-Mode Drivers','Process32',
        'Pool Tag','Pool Party','VAD Tree','Event Tracing','ETW','EventSource','Boot Critical',
        'Crash Dump','BugCheck','BSOD','Driver Architect','KMDF','WDF','Filter Driver','Mini-?Filter',
        'IRP\b','IO Request Pack','IRQL','DPC ','APC ','LSASS','Kerberos.*Windows','Microsoft Builds',
        'David Cutler','Lucovsky','Singularity Project','Detours - Binary','Lookaside','Pool Quick',
        'CASEVision','ClearCase','MSDN Journal','MSDN -','MSDN Export','Software Tracing','MOF',
        'Marius Tivadar','David Probert','Alex Ionescu','Russinovich','Hivercon','BlueHat','OSR',
        'NT Insider','Linux Kernel Hidden','Reactor.*Object','Microsoft.*Empirical','Software Engineering Odyssey',
        'Engineering Better Software at Microsoft','Original Microsoft','How Microsoft Builds','Inside The Deal',
        'Influence of Organizational Structure','Inside the Deal','Forgotten Interface','Dark Side of Winsock',
        'Microsoft Portable Executable','Microsoft Source','MSBuild','SAL\b','PREfast'
    )},
    @{ Name = 'Mathematics-and-Statistics'; Patterns = @(
        'Calculus','Linear Algebra','Algebra ','Mathematics','Mathematical','Probability','Statistic',
        'Geometry','Topology','Differential','Integral','Trigonom','Trig\b','Number Theory','Set Theory',
        'Graph Theory','Combinator','Discrete Math','Permutation','Vector Calculus','Multivariate',
        'Mihai Patrascu','Chinese Remainder','Mersenne','Ramanujan','Erdos','Lockhart','Mathematician','Grothendieck',
        'Background.*BLAS','BLAS - 1979','Lawson_BLAS',
        'Bayes','Bayesian','Markov','Stochastic','Optimization Theory','Constrained Optim','Convex Optim',
        'Maximum and Minim','Minimum and Max','Linear Programming','Simplex','Lagrange','Hessian','Gradient',
        'Tensor\b','Vector Space','Dimension','Hilbert','Banach','Probabilistic','Random Variable',
        'Hypothesis','Regression','PCA','Logistic Regress','Bumper Sticker','Cookbook.*Statist',
        'Probabilistic Theor','Mihai','Cosmology','Physis','Differential Equations','Boosting Vector Calc',
        'Math for Machine Learning','Algebra, Topology','Notes on Differential','Foundations of Data Sci',
        'Pure Mathmat','Pure Math','Number','Abstract Algebra','Mathematical Theory','Functional Analy',
        'Real Analysis','Measure Theory','Game Theory','Errors of Probabil','Lockhart','Lambda Calculus',
        'Notes on Linear','Calculus.*Computer','Foundations.*Database','Foundations.*Data Science',
        'Information Theory.*Intelligent','Math.*Cheat','Probability.*Cookbook','Markov Chains and Random Walks',
        'Long Gaps Between Primes','Multidigit Multiplication','de Bruijn','Sensitivity Conjecture',
        'Cosine.*CORDIC','Sine and Cosine','Roots.*Trigonometric','Trigon','Curves and Surfaces',
        'Brief Calculus','Crowell','Hefferon','Axler','Thirty-three Miniatures','Folding and Unfolding',
        'Notorious Four-Color','Proofs and Refutations','Origins of the Simplex','Mihai Patrascu',
        'Robust Combinatorial','Faster Cutting Plane','Constraint Propagation'
    )},
    @{ Name = 'Software-Engineering-and-Tools'; Patterns = @(
        'Software Engineer','Software Process','Test(ing)? Driven','Test-Driven','TDD','Unit Test',
        'Integration Test','Code Review','Refactor','Design Pattern','Domain-Driven','Agile','Scrum',
        'Waterfall','Six Sigma','Documentation','Style Guide','Coding Standard','Coding Guidelines',
        'Software Quality','Bug Inves','Bug Repor','Bug Detect','Empirical','Lint','Code Smell',
        'Continuous Integ','CI/CD','GitHub','Git ','Subversion','Mercurial','Build System',
        'Vim ','Emacs','VS Code','VSCode','\bIDE\b','Eclipse','IntelliJ','\bLSP\b','LaTeX','LATEX',
        'Doxygen','Sphinx','Asciidoc','Markdown','Pandoc','Jupyter','Org-mode','Cheat Sheet','Vim Book','Vim for Humans',
        'Cheatsheet','Quick Reference','Tutorial','Reference Card','User Guide','User Manual',
        'Programmer''s Guide','Quick Guide','How to Read a Paper','Patterns Of Software','Bumper Sticker',
        'Coding Practice','Unreliable Guide','Production Tracing','Setting Up.*Production','How to Test',
        'Profil(er|ing)','Verification','Verifier','Static Driver','Coverity','How to Write','How To Write',
        'Pattern Lang','Software Community','Realizing Quality Improv','Bias Against','Egocent',
        'Cognitive Bias','Mental Model','Goal Setting','Goals Gone Wild','Reversal Test','Mobile Computing',
        'When Corrections Fail','Saddest Moment','Slow Winter','Night Watch','Why Threads Are A Bad',
        'Code of Ethic','Software Engineering','Patterns Of Soft','Tools and Examples','Build Systems',
        'Code Quality','How Microsoft Builds','How To.*Code','Engineering Better','SAL ','Code Re-Random',
        'BPTX_2014','Influence of Organiz','Choosing a Good','How To Read','Out of the Tar Pit',
        'Mathematician''s Lament','Bias Against Creativ','Can''t Get To Performing','Mobile Computing.*Hornet',
        'Misuse of Colour','Dueling UNIXes','UNIX Wars',
        'Competitive Programmer','Cortical representations','Designing COM','Fundamentals of COM',
        'Hideous Name','Robust Beauty','This World of Ours','Saddest Moment','Bumper Sticker',
        'Software Tracing','Pattern Lang','Goals Gone','Egocentrism','Pattern Match','Learn OpenGL',
        'Computer System.*Research','Pre-print','Continuous Linked','Salomon Smith','Dodd-Frank',
        'Equity Options','Hedge','Stock Market','Limit Order','Inside The Deal','Inside the Deal',
        'Rich vs King','Entrepreneur','Rewriting History','Open Market Operations','Economics of Immediate',
        'Big Data.*Econometric','Continuous Linked Settle','Open Market','Mistakes That Led','Mistakes that led',
        'Dodd-Frank','Stress Test','Chinese Remainder','SWIFT Message','Foreign Exchange','Programmer.*Aptitude',
        'Wheat and Chaff','Code Abstraction','Self-Adjusting','How to Test','Production Monitoring',
        'Estimating Flight','Anomalous Aerial','Anomalous Unidentified','Aerial Vehicle','UAP\b',
        'Pre-Assess','Errors of Probability','Goodwin Paper','Digital at Work','Digital Equipment',
        'Patrick Lambert','Forgotten Interface','Continuous Linked','Apparent','Operational Risk',
        'CPU Performance Counter.*Security','Boolean Func.*Manipulation','Verification Techn',
        'Truncated','Foundations of Data Sci','Foundations of Database','Choosing a Good Chart',
        'Code Standard','Style Guide','Coding Standard','Coding Guidelines','Hardware is the new software'
    )}
)

# Final fallback bucket.
$miscCategory = 'Misc'

if ($Trace) {
    foreach ($rule in $rules) {
        foreach ($pat in $rule.Patterns) {
            if ($Trace -match $pat) {
                Write-Host ("MATCH: [{0}] pattern: '{1}'" -f $rule.Name, $pat)
                return
            }
        }
    }
    Write-Host "NO MATCH (would go to Misc)"
    return
}

# Get all top-level files (skip directories).
$rootDir = Get-Location
$allItems = Get-ChildItem -Path $rootDir -File

$assignments = @{}
foreach ($cat in $rules.Name) { $assignments[$cat] = @() }
$assignments[$miscCategory] = @()

$keepCount = 0
foreach ($item in $allItems) {
    if ($keepAtRoot -contains $item.Name) { $keepCount++; continue }

    $name = $item.Name
    $matched = $null
    foreach ($rule in $rules) {
        foreach ($pat in $rule.Patterns) {
            if ($name -match $pat) {
                $matched = $rule.Name
                break
            }
        }
        if ($matched) { break }
    }
    if (-not $matched) { $matched = $miscCategory }
    $assignments[$matched] += $item
}

# Print stats
$total = ($assignments.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
Write-Host ""
Write-Host "=== Categorization Plan ==="
Write-Host ("Total files to move: {0} (keeping {1} at root)" -f $total, $keepCount)
Write-Host ""
$assignments.GetEnumerator() | Sort-Object { -$_.Value.Count } | ForEach-Object {
    Write-Host ("{0,5}  {1}" -f $_.Value.Count, $_.Key)
}

if ($DryRun) {
    Write-Host ""
    Write-Host "=== Dry Run: Sample assignments ==="
    foreach ($entry in ($assignments.GetEnumerator() | Sort-Object Key)) {
        if ($entry.Value.Count -eq 0) { continue }
        Write-Host ""
        Write-Host ("--- {0} ({1}) ---" -f $entry.Key, $entry.Value.Count)
        $sampleCount = if ($ShowAll) { 5000 } elseif ($entry.Key -eq 'Misc') { 100 } else { 5 }
        $entry.Value | Select-Object -First $sampleCount | ForEach-Object { Write-Host ("  {0}" -f $_.Name) }
        if ($entry.Value.Count -gt $sampleCount) { Write-Host ("  ... and {0} more" -f ($entry.Value.Count - $sampleCount)) }
    }
    return
}

# Create category folders and move files.
Write-Host ""
Write-Host "=== Moving files ==="
foreach ($entry in $assignments.GetEnumerator()) {
    $cat = $entry.Key
    $files = $entry.Value
    if ($files.Count -eq 0) { continue }
    $catPath = Join-Path $rootDir $cat
    if (-not (Test-Path $catPath)) {
        New-Item -ItemType Directory -Path $catPath | Out-Null
    }
    foreach ($f in $files) {
        $dest = Join-Path $catPath $f.Name
        if (Test-Path $dest) {
            Write-Host ("[skip exists] {0} -> {1}" -f $f.Name, $cat) -ForegroundColor Yellow
            continue
        }
        Move-Item -LiteralPath $f.FullName -Destination $dest
    }
    Write-Host ("[done] {0} ({1} files)" -f $cat, $files.Count) -ForegroundColor Green
}

Write-Host ""
Write-Host "Done."

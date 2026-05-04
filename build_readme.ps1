# Generates README.md from the categorized directory structure.

$ErrorActionPreference = 'Stop'

# Order categories thoughtfully, not just alphabetically.
$categoryOrder = @(
    'Algorithms-and-Data-Structures',
    'Compilers-and-Programming-Languages',
    'Computer-Architecture',
    'Concurrency-and-Parallelism',
    'Operating-Systems',
    'Windows-Internals',
    'Memory-Management',
    'Storage-and-File-Systems',
    'Networking',
    'Distributed-Systems',
    'Databases',
    'GPU-and-Graphics',
    'AI-and-Machine-Learning',
    'Cryptography-and-Security',
    'Reverse-Engineering-and-Binary-Analysis',
    'Performance-and-Optimization',
    'Compression-and-Information-Theory',
    'Mathematics-and-Statistics',
    'Software-Engineering-and-Tools',
    'Misc'
)

$blurbs = @{
    'Algorithms-and-Data-Structures' = 'Sorting, hashing (perfect/minimal/cuckoo/locality-sensitive), tries and suffix structures, graphs, succinct/probabilistic data structures, search, and complexity-theoretic foundations.'
    'Compilers-and-Programming-Languages' = 'Compiler construction, JITs, parsers, type systems, formal verification, SAT/SMT, language references (C, C++, Python, R, Rust, Haskell, Go, ...), and PL theory.'
    'Computer-Architecture' = 'Intel/AMD/ARM/SPARC manuals, microarchitecture, instruction sets (x86, x86-64, AVX/SSE/MMX), caches, TLBs, branch predictors, NVDIMM, PCIe, and BIOS/ACPI.'
    'Concurrency-and-Parallelism' = 'Lock-free / wait-free algorithms, transactional memory, RCU, atomics, memory consistency, vectorization, SIMD programming, threading, futexes, and parallel runtimes.'
    'Operating-Systems' = 'Kernels and OS internals across Linux, the BSDs, Solaris, macOS/Mach, BeOS, Plan 9, ReactOS, xv6, and the Mach/UNIX heritage. Includes scheduling, virtual memory, drivers, and system calls.'
    'Windows-Internals' = 'NT kernel internals, WinDbg, ETW, IO completion ports, ALPC, kernel pool, drivers (KMDF/WDF), and MSDN-era deep dives. Includes Microsoft engineering culture pieces.'
    'Memory-Management' = 'Allocators (malloc, jemalloc, Hoard, slab/vmem), garbage collection, persistent memory programming, prefetching, and reference counting.'
    'Storage-and-File-Systems' = 'NTFS, ZFS, APFS, BeFS, NVMe, io_uring, Fibre Channel, persistent storage, durability, and storage-system case studies.'
    'Networking' = 'TCP/HTTP/SPDY, BGP, RDMA, DPDK, 10G+ Ethernet, network-stack scaling, IO acceleration, and event-driven server architectures.'
    'Distributed-Systems' = 'Replication, consensus (Paxos/Raft), CRDTs, distributed tracing (Dapper, Canopy), warehouse-scale systems, and large-scale data processing.'
    'Databases' = 'Relational and column-stores, B+/Bw/Fractal trees, query processing and optimization, OLAP/OLTP, indexing (bitmap, inverted), Oracle, and DB internals.'
    'GPU-and-Graphics' = 'CUDA programming, NVIDIA/AMD GPU architectures, OpenGL/OpenCL/HIP, ray tracing, the graphics pipeline, GPU sorting/hashing, and visualization.'
    'AI-and-Machine-Learning' = 'Neural networks, deep learning, LLMs (GPT/LLaMA/DeepSeek), transformers, attention mechanisms, RL, embeddings, and classical ML.'
    'Cryptography-and-Security' = 'AES/SHA/Keccak, side-channel attacks (Spectre, Meltdown, Flush+Reload), exploitation, ASLR, CFG, security engineering, and forensics.'
    'Reverse-Engineering-and-Binary-Analysis' = 'Disassembly, IDA / Hex-Rays, PE/ELF formats, anti-debugging, symbolic execution, dynamic instrumentation (Pin/DynamoRIO), and assembly references.'
    'Performance-and-Optimization' = 'Profiling, tracing, latency analysis, microbenchmarking, optimization guides, and high-performance computing techniques.'
    'Compression-and-Information-Theory' = 'Huffman, arithmetic, Burrows-Wheeler, integer/unary/Golomb coding, Shannon-era foundations, and bitmap/index compression.'
    'Mathematics-and-Statistics' = 'Calculus, linear algebra, probability, statistics, discrete math, graph theory, optimization, and biographical/historical pieces.'
    'Software-Engineering-and-Tools' = 'Cheat sheets, style guides, version control, editors (Vim, Emacs), LaTeX/Doxygen/Pandoc, code-review research, and SE essays.'
    'Misc' = 'Truly miscellaneous: essays, demoscene productions, business/finance specs, aviation, and a handful of items that resist neat categorization.'
}

$root = Get-Location
$lines = New-Object System.Collections.Generic.List[string]

# Total counts up front
$totalFiles = 0
$catCounts = @{}
foreach ($cat in $categoryOrder) {
    $path = Join-Path $root $cat
    if (Test-Path $path) {
        $count = (Get-ChildItem -Path $path -File -Recurse).Count
        $catCounts[$cat] = $count
        $totalFiles += $count
    } else {
        $catCounts[$cat] = 0
    }
}

$activeCats = ($categoryOrder | Where-Object { $catCounts[$_] -gt 0 }).Count
$pdfCount = (Get-ChildItem -Recurse -File -Filter '*.pdf').Count

# Header
$lines.Add('# CSS-Library')
$lines.Add('')
$lines.Add('> A curated, organized library of **{0:N0} technically-oriented papers, books, and references** spanning the breadth of computer science.' -f $totalFiles)
$lines.Add('')
$lines.Add(('![files](https://img.shields.io/badge/files-{0}-blue) ![categories](https://img.shields.io/badge/categories-{1}-green) ![PDFs](https://img.shields.io/badge/PDFs-{2}-red)' -f $totalFiles, $activeCats, $pdfCount))
$lines.Add('')
$lines.Add('Originally a flat dump of PDFs, now sorted into 20 thematic categories so you can actually find what you''re looking for. Topics range from CPU manuals and OS kernels to deep-learning papers, compilers, databases, GPU programming, and reverse engineering.')
$lines.Add('')
$lines.Add('All content copyright the respective author(s). I make a concerted effort to not publish anything here if the copyright does not permit it. If you spot something that shouldn''t be here, please open an issue or PR.')
$lines.Add('')
$lines.Add('---')
$lines.Add('')

# Table of contents
$lines.Add('## Table of Contents')
$lines.Add('')
$lines.Add('| # | Category | Count | Topics |')
$lines.Add('|---|---|---:|---|')
$idx = 1
foreach ($cat in $categoryOrder) {
    $count = $catCounts[$cat]
    if ($count -eq 0) { continue }
    $blurb = $blurbs[$cat]
    $anchor = $cat.ToLower()
    $display = $cat -replace '-', ' '
    $lines.Add(('| {0} | [{1}](#{2}) | {3:N0} | {4} |' -f $idx, $display, $anchor, $count, $blurb))
    $idx++
}
$lines.Add('')
$lines.Add('**Total: {0:N0} files**' -f $totalFiles)
$lines.Add('')

# Repo layout
$lines.Add('## Repository Layout')
$lines.Add('')
$lines.Add('```text')
$lines.Add('css-library/')
foreach ($cat in $categoryOrder) {
    $count = $catCounts[$cat]
    if ($count -eq 0) { continue }
    $lines.Add(('|-- {0}/  ({1} files)' -f $cat, $count))
}
$lines.Add('|-- README.md')
$lines.Add('`-- organize.ps1   # idempotent re-categorization script')
$lines.Add('```')
$lines.Add('')
$lines.Add('---')
$lines.Add('')

# Per-category sections
$lines.Add('## Catalog')
$lines.Add('')
$lines.Add('Each category section below is collapsible. Click to expand the full file listing.')
$lines.Add('')

foreach ($cat in $categoryOrder) {
    $count = $catCounts[$cat]
    if ($count -eq 0) { continue }
    $display = $cat -replace '-', ' '
    $blurb = $blurbs[$cat]
    $path = Join-Path $root $cat

    $lines.Add(('### {0}' -f $display))
    $lines.Add('')
    $lines.Add($blurb)
    $lines.Add('')
    $lines.Add(('<details>'))
    $lines.Add(('<summary><b>{0:N0} files</b> -- click to expand</summary>' -f $count))
    $lines.Add('')

    # List files (only the top-level ones; recursive _files asset dirs are skipped from the listing)
    $files = Get-ChildItem -Path $path -File | Sort-Object Name
    $assetDirs = Get-ChildItem -Path $path -Directory | Sort-Object Name
    foreach ($f in $files) {
        $name = $f.Name
        # Build a relative URL with proper percent-encoding of spaces and special chars
        $relPath = "$cat/$name"
        $encoded = [System.Uri]::EscapeDataString($name)
        # Use raw spaces -> %20 etc.; markdown handles ( ) but use safer encoding
        $url = "$cat/$encoded"
        $lines.Add(('- [{0}]({1})' -f ($name -replace '\|', '\|'), $url))
    }
    if ($assetDirs.Count -gt 0) {
        $lines.Add('')
        $lines.Add('**Subfolders:**')
        foreach ($d in $assetDirs) {
            $assetCount = (Get-ChildItem -Path $d.FullName -File -Recurse).Count
            $encoded = [System.Uri]::EscapeDataString($d.Name)
            $note = if ($d.Name -match '_files$') { 'HTML page assets' } else { 'topical subfolder' }
            $lines.Add(('- [{0}/]({1}/{2}/) -- {3} files ({4})' -f $d.Name, $cat, $encoded, $assetCount, $note))
        }
    }
    $lines.Add('')
    $lines.Add('</details>')
    $lines.Add('')
}

# Footer
$lines.Add('---')
$lines.Add('')
$lines.Add('## How the categorization works')
$lines.Add('')
$lines.Add('Files are sorted by `organize.ps1`, which runs through a priority-ordered list of regex rules (first match wins). The script is **idempotent** -- you can drop new PDFs into the repository root and re-run it; existing categorized files are not touched.')
$lines.Add('')
$lines.Add('```powershell')
$lines.Add('# Preview what would happen, with bucket counts:')
$lines.Add('.\organize.ps1 -DryRun')
$lines.Add('')
$lines.Add('# Show the full category listing in the dry-run:')
$lines.Add('.\organize.ps1 -DryRun -ShowAll')
$lines.Add('')
$lines.Add('# Trace which rule matches a particular filename:')
$lines.Add('.\organize.ps1 -Trace "FlashAttention-3 - Fast and Accurate Attention.pdf"')
$lines.Add('')
$lines.Add('# Run for real:')
$lines.Add('.\organize.ps1')
$lines.Add('```')
$lines.Add('')
$lines.Add('## Notes')
$lines.Add('')
$lines.Add('- Files appear in exactly one category -- the highest-priority match wins, so e.g. *"GPU Hash Tables"* lands in **GPU and Graphics** rather than **Algorithms and Data Structures**.')
$lines.Add('- A handful of HTML-style pages keep their `_files` sidecar asset folders alongside them.')
$lines.Add('- The **Misc** bucket is intentionally narrow: only items that genuinely don''t fit elsewhere (essays, finance specs, an aviation handbook, etc.) end up there.')
$lines.Add('')

# Write the README
$content = ($lines -join "`r`n")
[System.IO.File]::WriteAllText((Join-Path $root 'README.md'), $content, [System.Text.UTF8Encoding]::new($false))

Write-Host ("Wrote README.md ({0:N0} lines, {1:N0} files cataloged across {2} categories)." -f $lines.Count, $totalFiles, ($categoryOrder | Where-Object { $catCounts[$_] -gt 0 }).Count)

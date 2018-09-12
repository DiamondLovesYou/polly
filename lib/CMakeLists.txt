set(LLVM_NO_RTTI 1)

set(ISL_CODEGEN_FILES
    CodeGen/IslAst.cpp
    CodeGen/IslExprBuilder.cpp
    CodeGen/IslNodeBuilder.cpp
    CodeGen/CodeGeneration.cpp)

if (GPU_CODEGEN)
  set (GPGPU_CODEGEN_FILES
       CodeGen/PPCGCodeGeneration.cpp
       CodeGen/ManagedMemoryRewrite.cpp
       )
endif (GPU_CODEGEN)

# Compile ISL into a separate library.
add_subdirectory(External)

set(POLLY_HEADER_FILES)
if (MSVC_IDE OR XCODE)
  file(GLOB_RECURSE POLLY_HEADER_FILES "${POLLY_SOURCE_DIR}/include/polly/*.h")
endif ()

# Polly-ACC requires the NVPTX backend to work. Ask LLVM about its libraries.
set(nvptx_libs)
if (GPU_CODEGEN)
  # This call emits an error if they NVPTX backend is not enable.
  llvm_map_components_to_libnames(nvptx_libs NVPTX)
endif ()

set(LLVM_COMPONENTS
  Support
  Core
  ScalarOpts
  InstCombine
  TransformUtils
  Analysis
  ipo
  MC
  Passes
  Linker
  IRReader
  ${nvptx_libs}
  # The libraries below are required for darwin: http://PR26392
  BitReader
  MCParser
  Object
  ProfileData
  Target
  Vectorize

  PollyISL
  )

# Additional dependencies for Polly-ACC.
if (GPU_CODEGEN)
  list(APPEND LLVM_COMPONENTS PollyPPCG)
endif ()

# Use an object-library to add the same files to multiple libs without requiring
# the sources them to be recompiled for each of them.
add_llvm_library(Polly
  Analysis/DependenceInfo.cpp
  Analysis/PolyhedralInfo.cpp
  Analysis/ScopDetection.cpp
  Analysis/ScopDetectionDiagnostic.cpp
  Analysis/ScopInfo.cpp
  Analysis/ScopBuilder.cpp
  Analysis/ScopGraphPrinter.cpp
  Analysis/ScopPass.cpp
  Analysis/PruneUnprofitable.cpp
  CodeGen/BlockGenerators.cpp
  ${ISL_CODEGEN_FILES}
  CodeGen/LoopGenerators.cpp
  CodeGen/LoopGeneratorsGOMP.cpp
  CodeGen/LoopGeneratorsKMP.cpp
  CodeGen/IRBuilder.cpp
  CodeGen/Utils.cpp
  CodeGen/RuntimeDebugBuilder.cpp
  CodeGen/CodegenCleanup.cpp
  CodeGen/PerfMonitor.cpp
  ${GPGPU_CODEGEN_FILES}
  Exchange/JSONExporter.cpp
  Support/GICHelper.cpp
  Support/SCEVAffinator.cpp
  Support/SCEVValidator.cpp
  Support/RegisterPasses.cpp
  Support/ScopHelper.cpp
  Support/ScopLocation.cpp
  Support/ISLTools.cpp
  Support/DumpModulePass.cpp
  Support/VirtualInstruction.cpp
  Transform/Canonicalization.cpp
  Transform/CodePreparation.cpp
  Transform/DeadCodeElimination.cpp
  Transform/ScheduleOptimizer.cpp
  Transform/FlattenSchedule.cpp
  Transform/FlattenAlgo.cpp
  Transform/ForwardOpTree.cpp
  Transform/DeLICM.cpp
  Transform/ZoneAlgo.cpp
  Transform/Simplify.cpp
  Transform/MaximalStaticExpansion.cpp
  Transform/RewriteByReferenceParameters.cpp
  Transform/ScopInliner.cpp
  ${POLLY_HEADER_FILES}

  OBJECT
  STATIC

  DEPENDS intrinsics_gen

  LINK_COMPONENTS ${LLVM_COMPONENTS}
  )
set_target_properties(Polly PROPERTIES FOLDER "Polly")

add_llvm_library(LLVMPolly SHARED
  Polly/Polly.cpp
  $<TARGET_OBJECTS:obj.Polly>

  LINK_COMPONENTS ${LLVM_COMPONENTS}
  )

set_target_properties(LLVMPolly
  PROPERTIES
  FOLDER "Polly"
  LINKER_LANGUAGE CXX
  PREFIX ""
  )

add_custom_target(PollyUnitTests)
set_target_properties(PollyUnitTests PROPERTIES FOLDER "Polly")

# add_polly_unittest(test_dirname file1.cpp file2.cpp)
#
# Will compile the list of files together and link against Polly and its dependences.
function(add_polly_unittest test_name)
  list(APPEND LLVM_LINK_COMPONENTS Analysis Core Passes Polly PollyISL)
  add_unittest(PollyUnitTests ${test_name} ${ARGN})
  set_property(TARGET ${test_name} PROPERTY FOLDER "Polly")
endfunction()

add_subdirectory(Isl)
add_subdirectory(Flatten)
add_subdirectory(DeLICM)
add_subdirectory(ScopPassManager)
add_subdirectory(ScheduleOptimizer)
add_subdirectory(Support)

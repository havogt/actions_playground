cmake_minimum_required(VERSION 3.12.4)

project(test_actions LANGUAGES CXX)

enable_testing()

add_executable(testprogram test.cc)
add_test(NAME testprogram COMMAND $<TARGET_FILE:testprogram>)

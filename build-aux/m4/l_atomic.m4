dnl Copyright (c) 2015 Tim Kosse <tim.kosse@filezilla-project.org>
dnl Copying and distribution of this file, with or without modification, are
dnl permitted in any medium without royalty provided the copyright notice
dnl and this notice are preserved. This file is offered as-is, without any
dnl warranty.

# Clang, when building for 32-bit,
# and linking against libstdc++, requires linking with
# -latomic if using the C++ atomic library.
# Can be tested with: clang++ -std=c++20 test.cpp -m32
#
# Sourced from http://bugs.debian.org/797228

m4_define([_CHECK_ATOMIC_testbody], [[
  #include <atomic>
  #include <cstdint>
  #include <chrono>

  using namespace std::chrono_literals;

  int main() {
    std::atomic<bool> lock{true};
    lock.exchange(false);

    std::atomic<std::chrono::seconds> t{0s};
    t.store(2s);
    auto t1 = t.load();
    t.compare_exchange_strong(t1, 3s);

    std::atomic<double> d{};
    d.store(3.14);
    auto d1 = d.load();

    std::atomic<int64_t> a{};
    int64_t v = 5;
    int64_t r = a.fetch_add(v);
    return static_cast<int>(r);
  }
]])

AC_DEFUN([CHECK_ATOMIC], [

  AC_LANG_PUSH(C++)
  TEMP_CXXFLAGS="$CXXFLAGS"
  CXXFLAGS="$CXXFLAGS $PTHREAD_CFLAGS"

  AC_MSG_CHECKING([whether std::atomic can be used without link library])

  AC_LINK_IFELSE([AC_LANG_SOURCE([_CHECK_ATOMIC_testbody])],[
      AC_MSG_RESULT([yes])
    ],[
      AC_MSG_RESULT([no])
      LIBS="$LIBS -latomic"
      AC_MSG_CHECKING([whether std::atomic needs -latomic])
      AC_LINK_IFELSE([AC_LANG_SOURCE([_CHECK_ATOMIC_testbody])],[
          AC_MSG_RESULT([yes])
        ],[
          AC_MSG_RESULT([no])
          AC_MSG_FAILURE([cannot figure out how to use std::atomic])
        ])
    ])

  CXXFLAGS="$TEMP_CXXFLAGS"
  AC_LANG_POP
])

# This file is part of MXE. See LICENSE.md for licensing information.

# partial module - included by src/cmake/CMakeLists.txt

set(TGT test-${PKG}-cmake)
set(QT_MAJOR 5 CACHE STRING "")

enable_language(CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt${QT_MAJOR} ${PKG_VERSION} EXACT REQUIRED COMPONENTS Widgets)

add_executable(${TGT} ${CMAKE_CURRENT_LIST_DIR}/qt-test.cpp)

target_link_libraries(${TGT} Qt::Widgets)

# reduce size of static binary by excluding unnecessary plugins
# https://doc.qt.io/qt-5/qtcore-cmake-qt5-import-plugins.html
qt_import_plugins(${TGT}
    INCLUDE_BY_TYPE platforms
    EXCLUDE_BY_TYPE imageformats
    EXCLUDE_BY_TYPE sqldrivers)

install(TARGETS ${TGT} DESTINATION bin)

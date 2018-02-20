#! /usr/bin/env python
# encoding: utf-8
# requires waf: https://github.com/waf-project/waf.git

VERSION='0.0.1'
APPNAME='cudax'

top = '.'

from waflib import Configure, Logs, Utils

def options(opt):
    opt.load('compiler_cxx cuda')

def configure(conf):
    conf.load('compiler_cxx')
    conf.check_cfg(package='mpi', args=['--cflags', '--libs'], uselib_store='mpi')
    conf.load('cuda', tooldir='.')


def build(bld):
    bld.objects(source = 'simpleMPI.cu',
                features = 'cxx',
                cxxflags = '-Xcompiler -fPIC',
                target = 'kernel')
    bld.program(source = 'simpleMPI.cpp',
                features = 'cxxprogram',
                linkflags = '-lmpi_cxx',
                target = 'simpleMPI',
                use = 'mpi kernel CUDA CUDART')



FROM alpine:latest as clang-format-build

# Build dependencies
RUN apk update && apk add git build-base ninja cmake python3

# Pass `--build-arg LLVM_TAG=master` for latest llvm commit
ARG LLVM_TAG
ENV LLVM_TAG ${LLVM_TAG:-llvmorg-6.0.1}

# Download and setup
WORKDIR /build
RUN git clone --branch ${LLVM_TAG} --depth 1 https://github.com/llvm/llvm-project.git
WORKDIR /build/llvm-project
RUN mv clang llvm/tools
RUN mv libcxx llvm/projects

# Build
WORKDIR llvm/build
RUN cmake -GNinja -DLLVM_BUILD_STATIC=ON -DLLVM_ENABLE_LIBCXX=ON ..
RUN ninja clang-format

# Install
FROM alpine:latest
RUN apk update && apk add git python

COPY --from=clang-format-build /build/llvm-project/llvm/build/bin/clang-format /usr/bin
COPY --from=clang-format-build /build/llvm-project/llvm/tools/clang/tools/clang-format/clang-format-diff.py /usr/bin

WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "/entrypoint.sh"]


#ENTRYPOINT ["clang-format-diff.py"]
#CMD ["--help"]

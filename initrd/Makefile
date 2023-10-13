CWD=$(shell pwd)

arm64-build:
	@bash ./bootstrap.bash arm64

amd64-build:
	@bash ./bootstrap.bash amd64

rmstat:
	@printf "\n"
	rm -rf "$(CWD)"/states/cross-*
	rm -rf "$(CWD)"/states/await-*
	rm -rf "$(CWD)"/states/box-*
	@printf "\n"

rmcross:
	@printf "=> Delete cross toolchain temp folders\n"
	rm -rf "$(CWD)"/crosstmp/archives/*
	rm -rf "$(CWD)"/crosstmp/stamps/*
	rm -rf "$(CWD)"/crosstmp/build/*
	rm -rf "$(CWD)"/crosstmp/src/*

clean: rmstat rmcross
	@printf "Current work dir $(CWD)\n\n"
	@printf "=> Delete work directory:\n"
	rm -rf "$(CWD)"/work/*

	@printf "=> Delete out sysroot files:\n"
	rm -rf "$(CWD)"/output/*

	@printf "=> Delete toolchain tmp files:\n"
	rm -rf "$(CWD)"/toolchain/*
	rm -f "$(CWD)"/context.log

	@printf "\nClean workspace finish!\n"

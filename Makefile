MXMLC = ~/dev/flex_sdk_4.6/bin/mxmlc
SRC = src/Test.as
MAIN = src/Main.mxml
SWF = bin/output.swf
LIB = -library-path+=src/D.eval-1.1.swc -library-path+=src/greensock.swc

$(SWF) : $(SRC)
	    $(MXMLC) $(MAIN) -output $(SWF) $(LIB)

#~/dev/flex_sdk_4.6/bin/mxmlc src/Main.mxml -output bin/output.swf -library-path+=src/D.eval-1.1.swc -library-path+=src/greensock.swc 

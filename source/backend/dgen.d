﻿module backend.dgen;

//          Copyright Brian Schott (Sir Alaran) 2012.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

import stdx.d.lexer;
import stdx.d.ast;
import std.stdio;
import std.string;
import std.array;

template tagAndAccept(string tagName)
{
	immutable tagAndAccept = `output.writeln("<` ~ tagName ~ `>");`
		~ tagName ~ `.accept(this);`
			~ `output.writeln("</` ~ tagName ~ `>");`;
}

class DGenerator : ASTVisitor
{
	override void visit(const AddExpression addExpression)
	{
		output.writeln("<addExpression operator=\"", str(addExpression.operator) ,"\">");
		output.writeln("<left>");
		visit(addExpression.left);
		output.writeln("</left>");
		if (addExpression.right !is null)
		{
			output.writeln("<right>");
			visit(addExpression.right);
			output.writeln("</right>");
		}
		output.writeln("</addExpression>");
	}
	
	override void visit(const AliasDeclaration aliasDeclaration)
	{
		output.writeln("<aliasDeclaration line=\"", aliasDeclaration.name.line, "\">");
		writeDdoc(aliasDeclaration.comment);
		aliasDeclaration.accept(this);
		output.writeln("</aliasDeclaration>");
	}
	
	override void visit(const AliasInitializer aliasInitializer)
	{
		mixin (tagAndAccept!"aliasInitializer");
	}
	
	override void visit(const AliasThisDeclaration aliasThisDeclaration)
	{
		mixin (tagAndAccept!"aliasThisDeclaration");
	}
	
	override void visit(const AlignAttribute alignAttribute)
	{
		output.writeln("<alignAttribute align=\"", alignAttribute.intLiteral.text, "\">");
	}
	
	override void visit(const AndAndExpression andAndExpression)
	{
		output.writeln("<andAndExpression>");
		output.writeln("<left>");
		andAndExpression.left.accept(this);
		output.writeln("</left>");
		if (andAndExpression.right !is null)
		{
			output.writeln("<right>");
			andAndExpression.right.accept(this);
			output.writeln("</right>");
		}
		output.writeln("</andAndExpression>");
	}
	
	override void visit(const AndExpression andExpression)
	{
		output.writeln("<andExpression>");
		output.writeln("<left>");
		andExpression.left.accept(this);
		output.writeln("</left>");
		if (andExpression.right !is null)
		{
			output.writeln("<right>");
			andExpression.right.accept(this);
			output.writeln("</right>");
		}
		output.writeln("</andExpression>");
	}
	
	override void visit(const ArgumentList argumentList)
	{
		mixin (tagAndAccept!"argumentList");
	}
	
	override void visit(const Arguments arguments)
	{
		mixin (tagAndAccept!"arguments");
	}
	
	override void visit(const ArrayInitializer arrayInitializer)
	{
		mixin (tagAndAccept!"arrayInitializer");
	}
	
	override void visit(const ArrayLiteral arrayLiteral)
	{
		mixin (tagAndAccept!"arrayLiteral");
	}
	
	override void visit(const ArrayMemberInitialization arrayMemberInitialization)
	{
		mixin (tagAndAccept!"arrayMemberInitialization");
	}
	
	override void visit(const AssertExpression assertExpression)
	{
		output.writeln("<assertExpression>");
		output.writeln("<assertion>");
		assertExpression.assertion.accept(this);
		output.writeln("</assertion>");
		if (assertExpression.message !is null)
		{
			output.writeln("<message>");
			assertExpression.message.accept(this);
			output.writeln("</message>");
		}
		output.writeln("</assertExpression>");
	}
	
	override void visit(const AssignExpression assignExpression)
	{
		if (assignExpression.assignExpression is null)
			output.writeln("<assignExpression>");
		else
			output.writeln("<assignExpression operator=\"",
			               str(assignExpression.operator), "\">");
		assignExpression.accept(this);
		output.writeln("</assignExpression>");
	}
	
	override void visit(const AssocArrayLiteral assocArrayLiteral)
	{
		mixin (tagAndAccept!"assocArrayLiteral");
	}
	
	override void visit(const AtAttribute atAttribute)
	{
		output.writeln("<atAttribute>");
		if (atAttribute.identifier.type == tok!"")
			atAttribute.accept(this);
		else
			output.writeln("<identifier>", atAttribute.identifier.text, "</identifier>");
		output.writeln("</atAttribute>");
	}
	
	override void visit(const Attribute attribute)
	{
		output.writeln("<attribute>");
		if (attribute.attribute == tok!"")
			attribute.accept(this);
		else
			output.writeln(str(attribute.attribute));
		output.writeln("</attribute>");
	}
	
	override void visit(const AttributeDeclaration attributeDeclaration)
	{
		assert (attributeDeclaration !is null);
		mixin (tagAndAccept!"attributeDeclaration");
	}
	
	override void visit(const AutoDeclaration autoDec)
	{
		output.writeln("<autoDeclaration>");
		for (size_t i = 0; i < autoDec.identifiers.length; i++)
		{
			output.writeln("<item>");
			output.writeln("<name line=\"", autoDec.identifiers[i].line, "\">",
			autoDec.identifiers[i].text, "</name>");
			visit(autoDec.initializers[i]);
			output.writeln("</item>");
		}
		output.writeln("</autoDeclaration>");
	}
	
	override void visit(const BlockStatement blockStatement)
	{
		output.writeln("<blockStatement>");
		blockStatement.accept(this);
		output.writeln("</blockStatement>");
	}
	
	override void visit(const BodyStatement bodyStatement)
	{
		output.writeln("<bodyStatement>");
		bodyStatement.accept(this);
		output.writeln("</bodyStatement>");
	}
	
	override void visit(const BreakStatement breakStatement)
	{
		if (breakStatement.label.type == tok!"")
			output.writeln("<breakStatement/>");
		else
			output.writeln("<breakStatement label=\"", breakStatement.label.text, "\"/>");
	}
	
	override void visit(const BaseClass baseClass)
	{
		mixin (tagAndAccept!"baseClass");
	}
	
	override void visit(const BaseClassList baseClassList)
	{
		mixin (tagAndAccept!"baseClassList");
	}
	
	override void visit(const CaseRangeStatement caseRangeStatement)
	{
		output.writeln("<caseRangeStatement>");
		if (caseRangeStatement.low !is null)
		{
			output.writeln("<low>");
			visit(caseRangeStatement.low);
			output.writeln("</low>");
		}
		if (caseRangeStatement.high !is null)
		{
			output.writeln("<high>");
			visit(caseRangeStatement.high);
			output.writeln("</high>");
		}
		if (caseRangeStatement.declarationsAndStatements !is null)
			visit(caseRangeStatement.declarationsAndStatements);
		output.writeln("</caseRangeStatement>");
	}
	
	override void visit(const CaseStatement caseStatement)
	{
		mixin (tagAndAccept!"caseStatement");
	}
	
	override void visit(const CastExpression castExpression)
	{
		mixin (tagAndAccept!"castExpression");
	}
	
	override void visit(const CastQualifier castQualifier)
	{
		mixin (tagAndAccept!"castQualifier");
	}
	
	override void visit(const Catches catches)
	{
		mixin (tagAndAccept!"catches");
	}
	
	override void visit(const Catch catch_)
	{
		output.writeln("<catch>");
		catch_.accept(this);
		output.writeln("</catch>");
	}
	
	override void visit(const ClassDeclaration classDec)
	{
		output.writeln("<classDeclaration line=\"", classDec.name.line, "\">");
		output.writeln("<name>", classDec.name.text, "</name>");
		writeDdoc(classDec.comment);
		classDec.accept(this);
		output.writeln("</classDeclaration>");
	}
	
	override void visit(const CmpExpression cmpExpression)
	{
		mixin (tagAndAccept!"cmpExpression");
	}
	
	override void visit(const CompileCondition compileCondition)
	{
		mixin (tagAndAccept!"compileCondition");
	}
	
	override void visit(const ConditionalDeclaration conditionalDeclaration)
	{
		output.writeln("<conditionalDeclaration>");
		visit(conditionalDeclaration.compileCondition);
		output.writeln("<trueDeclarations>");
		foreach (dec; conditionalDeclaration.trueDeclarations)
			visit(dec);
		output.writeln("</trueDeclarations>");
		if (conditionalDeclaration.falseDeclaration !is null)
		{
			output.writeln("<falseDeclaration>");
			visit(conditionalDeclaration.falseDeclaration);
			output.writeln("</falseDeclaration>");
		}
		output.writeln("</conditionalDeclaration>");
	}
	
	override void visit(const ConditionalStatement conditionalStatement)
	{
		output.writeln("<conditionalStatement>");
		visit(conditionalStatement.compileCondition);
		output.writeln("<trueStatement>");
		visit(conditionalStatement.trueStatement);
		output.writeln("</trueStatement>");
		if (conditionalStatement.falseStatement !is null)
		{
			output.writeln("<falseStatement>");
			visit(conditionalStatement.falseStatement);
			output.writeln("</falseStatement>");
		}
		output.writeln("</conditionalStatement>");
	}
	
	override void visit(const Constraint constraint)
	{
		output.writeln("<constraint>");
		constraint.accept(this);
		output.writeln("</constraint>");
	}
	
	override void visit(const Constructor constructor)
	{
		mixin (tagAndAccept!"constructor");
	}
	
	override void visit(const ContinueStatement continueStatement)
	{
		if (continueStatement.label.type == tok!"")
			output.writeln("<continueStatement/>");
		else
			output.writeln("<continueStatement label=\"",
			               continueStatement.label.text, "\"/>");
	}
	
	override void visit(const DebugCondition debugCondition)
	{
		if (debugCondition.identifierOrInteger.type == tok!"")
			output.writeln("<debugCondition/>");
		else
			output.writeln("<debugCondition condition=\"",
			               debugCondition.identifierOrInteger.text, "\"/>");
	}
	
	override void visit(const DebugSpecification debugSpecification)
	{
		if (debugSpecification.identifierOrInteger.type == tok!"")
			output.writeln("<debugSpecification/>");
		else
			output.writeln("<debugSpecification condition=\"",
			               debugSpecification.identifierOrInteger.text, "\"/>");
	}
	
	override void visit(const Declaration declaration)
	{
		mixin (tagAndAccept!"declaration");
	}
	
	override void visit(const DeclarationsAndStatements declarationsAndStatements)
	{
		mixin (tagAndAccept!"declarationsAndStatements");
	}
	
	override void visit(const DeclarationOrStatement declarationOrStatement)
	{
		mixin (tagAndAccept!"declarationOrStatement");
	}
	
	override void visit(const Declarator declarator)
	{
		output.writeln("<declarator line=\"", declarator.name.line, "\">");
		output.writeln("<name>", declarator.name.text, "</name>");
		declarator.accept(this);
		output.writeln("</declarator>");
	}
	
	override void visit(const DefaultStatement defaultStatement)
	{
		mixin (tagAndAccept!"defaultStatement");
	}
	
	override void visit(const DeleteExpression deleteExpression)
	{
		mixin (tagAndAccept!"deleteExpression");
	}
	
	override void visit(const DeleteStatement deleteStatement)
	{
		mixin (tagAndAccept!"deleteStatement");
	}
	
	override void visit(const Deprecated deprecated_)
	{
		if (deprecated_.assignExpression !is null)
		{
			output.writeln("<deprecated>");
			deprecated_.accept(this);
			output.writeln("</deprecated>");
		}
		else
			output.writeln("<deprecated/>");
	}
	
	override void visit(const Destructor destructor)
	{
		mixin (tagAndAccept!"destructor");
	}
	
	override void visit(const DoStatement doStatement)
	{
		mixin (tagAndAccept!"doStatement");
	}
	
	override void visit(const EnumBody enumBody)
	{
		mixin (tagAndAccept!"enumBody");
	}
	
	override void visit(const EnumDeclaration enumDec)
	{
		output.writeln("<enumDeclaration line=\"", enumDec.name.line, "\">");
		writeDdoc(enumDec.comment);
		if (enumDec.name.type == tok!"identifier")
			output.writeln("<name>", enumDec.name.text, "</name>");
		enumDec.accept(this);
		output.writeln("</enumDeclaration>");
	}
	
	override void visit(const EnumMember enumMem)
	{
		output.writeln("<enumMember line=\"", enumMem.name.line, "\">");
		writeDdoc(enumMem.comment);
		enumMem.accept(this);
		output.writeln("</enumMember>");
	}
	
	override void visit(const EqualExpression equalExpression)
	{
		output.writeln("<equalExpression operator=\"", str(equalExpression.operator), "\">");
		output.writeln("<left>");
		equalExpression.left.accept(this);
		output.writeln("</left>");
		output.writeln("<right>");
		equalExpression.right.accept(this);
		output.writeln("</right>");
		output.writeln("</equalExpression>");
	}
	
	override void visit(const Expression expression)
	{
		output.writeln("<expression>");
		expression.accept(this);
		output.writeln("</expression>");
	}
	
	override void visit(const ExpressionStatement expressionStatement)
	{
		output.writeln("<expressionStatement>");
		expressionStatement.accept(this);
		output.writeln("</expressionStatement>");
	}
	
	override void visit(const FinalSwitchStatement finalSwitchStatement)
	{
		output.writeln("<finalSwitchStatement>");
		finalSwitchStatement.accept(this);
		output.writeln("</finalSwitchStatement>");
	}
	
	override void visit(const Finally finally_)
	{
		output.writeln("<finally>");
		finally_.accept(this);
		output.writeln("</finally>");
	}
	
	override void visit(const ForStatement forStatement)
	{
		output.writeln("<forStatement>");
		if (forStatement.declarationOrStatement !is null)
		{
			output.writeln("<initialization>");
			visit(forStatement.initialization);
			output.writeln("</initialization>");
		}
		if (forStatement.test !is null)
		{
			output.writeln("<test>");
			visit(forStatement.test);
			output.writeln("</test>");
		}
		if (forStatement.increment !is null)
		{
			output.writeln("<increment>");
			visit(forStatement.increment);
			output.writeln("</increment>");
		}
		visit(forStatement.declarationOrStatement);
		output.writeln("</forStatement>");
	}
	
	override void visit(const ForeachStatement foreachStatement)
	{
		output.writeln("<foreachStatement type=\"", str(
			foreachStatement.type), "\">");
		if (foreachStatement.foreachType !is null)
			visit(foreachStatement.foreachType);
		if (foreachStatement.foreachTypeList !is null)
			visit(foreachStatement.foreachTypeList);
		output.writeln("<low>");
		visit(foreachStatement.low);
		output.writeln("</low>");
		if (foreachStatement.high !is null)
		{
			output.writeln("<high>");
			visit(foreachStatement.high);
			output.writeln("</high>");
		}
		visit(foreachStatement.declarationOrStatement);
		output.writeln("</foreachStatement>");
	}
	
	override void visit(const ForeachType foreachType)
	{
		output.writeln("<foreachType>");
		foreach (constructor; foreachType.typeConstructors)
		{
			output.writeln("<typeConstructor>", str(constructor), "</typeConstructor>");
		}
		if (foreachType.type !is null)
			visit(foreachType.type);
		visit(foreachType.identifier);
		output.writeln("</foreachType>");
		
	}
	
	override void visit(const ForeachTypeList foreachTypeList)
	{
		mixin (tagAndAccept!"foreachTypeList");
	}
	
	override void visit(const FunctionAttribute functionAttribute)
	{
		mixin (tagAndAccept!"functionAttribute");
	}
	
	override void visit(const FunctionBody functionBody)
	{
		mixin (tagAndAccept!"functionBody");
	}
	
	override void visit(const FunctionCallExpression functionCallExpression)
	{
		mixin (tagAndAccept!"functionCallExpression");
	}
	
	override void visit(const FunctionCallStatement functionCallStatement)
	{
		mixin (tagAndAccept!"functionCallStatement");
	}
	
	override void visit(const FunctionDeclaration functionDec)
	{
		output.writeln("<functionDeclaration line=\"", functionDec.name.line, "\">");
		output.writeln("<name>", functionDec.name.text, "</name>");
		writeDdoc(functionDec.comment);
		if (functionDec.hasAuto)
			output.writeln("<auto/>");
		if (functionDec.hasRef)
			output.writeln("<ref/>");
		functionDec.accept(this);
		output.writeln("</functionDeclaration>");
	}
	
	override void visit(const FunctionLiteralExpression functionLiteralExpression)
	{
		output.writeln("<functionLiteralExpression type=\"",
		               str(functionLiteralExpression.functionOrDelegate), "\">");
		functionLiteralExpression.accept(this);
		output.writeln("</functionLiteralExpression>");
	}
	
	override void visit(const GotoStatement gotoStatement)
	{
		if (gotoStatement.label.type == tok!"default")
			output.writeln("<gotoStatement default=\"true\"/>");
		else if (gotoStatement.label.type == tok!"identifier")
			output.writeln("<gotoStatement label=\"", gotoStatement.label.text, "\"/>");
		else
		{
			output.writeln("<gotoStatement>");
			output.writeln("<case>");
			visit(gotoStatement.expression);
			output.writeln("</case>");
			output.writeln("</gotoStatement>");
		}
	}
	
	override void visit(const IdentifierChain identifierChain)
	{
		mixin (tagAndAccept!"identifierChain");
	}
	
	override void visit(const IdentifierList identifierList)
	{
		mixin (tagAndAccept!"identifierList");
	}
	
	override void visit(const IdentifierOrTemplateChain identifierOrTemplateChain)
	{
		mixin (tagAndAccept!"identifierOrTemplateChain");
	}
	
	override void visit(const IdentifierOrTemplateInstance identifierOrTemplateInstance)
	{
		mixin (tagAndAccept!"identifierOrTemplateInstance");
	}
	
	override void visit(const IdentityExpression identityExpression)
	{
		if (identityExpression.negated)
			output.writeln("<identityExpression operator=\"!is\">");
		else
			output.writeln("<identityExpression operator=\"is\">");
		output.writeln("<left>");
		visit(identityExpression.left);
		output.writeln("</left>");
		output.writeln("<right>");
		visit(identityExpression.right);
		output.writeln("</right>");
		output.writeln("</identityExpression>");
	}
	
	override void visit(const IfStatement ifStatement)
	{
		output.writeln("<ifStatement>");
		
		output.writeln("<condition>");
		if (ifStatement.identifier.type != tok!"")
		{
			if (ifStatement.type is null)
				output.writeln("<auto/>");
			else
				visit(ifStatement.type);
			visit(ifStatement.identifier);
		}
		ifStatement.expression.accept(this);
		output.writeln("</condition>");
		
		output.writeln("<then>");
		ifStatement.thenStatement.accept(this);
		output.writeln("</then>");
		
		if (ifStatement.elseStatement !is null)
		{
			output.writeln("<else>");
			ifStatement.elseStatement.accept(this);
			output.writeln("</else>");
		}
		output.writeln("</ifStatement>");
	}
	
	override void visit(const ImportBind importBind)
	{
		if (importBind.right.type == tok!"")
			output.writeln("<importBind symbol=\"", importBind.left.text, "\"/>");
		else
			output.writeln("<importBind symbol=\"", importBind.right.text,
			               "\" rename=\"", importBind.left.text, "\"/>");
	}
	
	override void visit(const ImportBindings importBindings)
	{
		mixin (tagAndAccept!"importBindings");
	}
	
	override void visit(const ImportDeclaration importDeclaration)
	{
		mixin (tagAndAccept!"importDeclaration");
	}
	
	override void visit(const ImportExpression importExpression)
	{
		mixin (tagAndAccept!"importExpression");
	}
	
	override void visit(const IndexExpression indexExpression)
	{
		mixin (tagAndAccept!"indexExpression");
	}
	
	override void visit(const InExpression inExpression)
	{
		if (inExpression.negated)
			output.writeln("<inExpression operator=\"!in\">");
		else
			output.writeln("<inExpression operator=\"in\">");
		output.writeln("<left>");
		visit(inExpression.left);
		output.writeln("</left>");
		output.writeln("<right>");
		visit(inExpression.right);
		output.writeln("</right>");
		output.writeln("</inExpression>");
	}
	
	override void visit(const InStatement inStatement)
	{
		mixin (tagAndAccept!"inStatement");
	}
	
	override void visit(const Initialize initialize)
	{
		if (initialize.statementNoCaseNoDefault is null)
			output.writeln("<initialize/>");
		else
		{
			output.writeln("<initialize>");
			visit(initialize.statementNoCaseNoDefault);
			output.writeln("</initialize>");
		}
	}
	
	override void visit(const Initializer initializer)
	{
		if (initializer.nonVoidInitializer is null)
			output.writeln("<initializer void=\"true\"/>");
		else
		{
			output.writeln("<initializer>");
			visit(initializer.nonVoidInitializer);
			output.writeln("</initializer>");
		}
	}
	
	override void visit(const InterfaceDeclaration interfaceDec)
	{
		output.writeln("<interfaceDeclaration line=\"", interfaceDec.name.line, "\">");
		output.writeln("<name>", interfaceDec.name.text, "</name>");
		writeDdoc(interfaceDec.comment);
		interfaceDec.accept(this);
		output.writeln("</interfaceDeclaration>");
	}
	
	override void visit(const Invariant invariant_)
	{
		output.writeln("<invariant>");
		writeDdoc(invariant_.comment);
		invariant_.accept(this);
		output.writeln("</invariant>");
	}
	
	override void visit(const IsExpression isExpression)
	{
		output.writeln("<isExpression>");
		visit(isExpression.type);
		if (isExpression.identifier.type != tok!"")
			visit(isExpression.identifier);
		if (isExpression.typeSpecialization !is null)
		{
			if (isExpression.equalsOrColon == tok!":")
				output.writeln("<colon/>");
			else
				output.writeln("<equals/>");
			visit(isExpression.typeSpecialization);
			if (isExpression.templateParameterList !is null)
				visit(isExpression.templateParameterList);
		}
		output.writeln("</isExpression>");
	}
	
	override void visit(const KeyValuePair keyValuePair)
	{
		output.writeln("<keyValuePair>");
		output.writeln("<key>");
		visit(keyValuePair.key);
		output.writeln("</key>");
		output.writeln("<value>");
		visit(keyValuePair.value);
		output.writeln("<value>");
		output.writeln("</keyValuePair>");
	}
	
	override void visit(const KeyValuePairs keyValuePairs)
	{
		mixin (tagAndAccept!"keyValuePairs");
	}
	
	override void visit (const LabeledStatement labeledStatement)
	{
		output.writeln("<labeledStatement label=\"",
		               labeledStatement.identifier.text ,"\">");
		visit(labeledStatement.declarationOrStatement);
		output.writeln("</labeledStatement>");
	}
	
	override void visit(const LambdaExpression lambdaExpression)
	{
		output.writeln("<lambdaExpression>");
		if (lambdaExpression.functionType == tok!"function")
			output.writeln("<function/>");
		if (lambdaExpression.functionType == tok!"delegate")
			output.writeln("<delegate/>");
		lambdaExpression.accept(this);
		output.writeln("</lambdaExpression>");
	}
	
	override void visit(const LastCatch lastCatch)
	{
		mixin (tagAndAccept!"lastCatch");
	}
	
	override void visit(const LinkageAttribute linkageAttribute)
	{
		if (linkageAttribute.hasPlusPlus)
			output.writeln("<linkageAttribute linkage=\"c++\"/>");
		else
			output.writeln("<linkageAttribute linkage=\"",
			               linkageAttribute.identifier.text, "\"/>");
	}
	
	override void visit(const MemberFunctionAttribute memberFunctionAttribute)
	{
		output.writeln("<memberFunctionAttribute>");
		if (memberFunctionAttribute.atAttribute is null)
			output.writeln(str(memberFunctionAttribute.tokenType));
		else
			memberFunctionAttribute.accept(this);
		output.writeln("</memberFunctionAttribute>");
	}
	
	override void visit(const MixinDeclaration mixinDeclaration)
	{
		mixin (tagAndAccept!"mixinDeclaration");
	}
	
	override void visit(const MixinExpression mixinExpression)
	{
		mixin (tagAndAccept!"mixinExpression");
	}
	
	override void visit(const MixinTemplateDeclaration mixinTemplateDeclaration)
	{
		mixin (tagAndAccept!"mixinTemplateDeclaration");
	}
	
	override void visit(const MixinTemplateName mixinTemplateName)
	{
		mixin (tagAndAccept!"mixinTemplateName");
	}
	
	override void visit(const Module module_)
	{
		output.writeln("<?xml version=\"1.0\"?>");
		output.writeln("<module>");
		module_.accept(this);
		output.writeln("</module>");
	}
	
	override void visit(const ModuleDeclaration moduleDeclaration)
	{
		mixin (tagAndAccept!"moduleDeclaration");
	}
	
	override void visit(const MulExpression mulExpression)
	{
		output.writeln("<mulExpression operator=\"", str(mulExpression.operator) ,"\">");
		output.writeln("<left>");
		visit(mulExpression.left);
		output.writeln("</left>");
		if (mulExpression.right !is null)
		{
			output.writeln("<right>");
			visit(mulExpression.right);
			output.writeln("</right>");
		}
		output.writeln("</mulExpression>");
	}
	
	override void visit(const NewAnonClassExpression newAnonClassExpression)
	{
		mixin (tagAndAccept!"newAnonClassExpression");
	}
	
	override void visit(const NewExpression newExpression)
	{
		mixin (tagAndAccept!"newExpression");
	}
	
	override void visit(const StatementNoCaseNoDefault statementNoCaseNoDefault)
	{
		mixin (tagAndAccept!"statementNoCaseNoDefault");
	}
	
	override void visit(const NonVoidInitializer nonVoidInitializer)
	{
		mixin (tagAndAccept!"nonVoidInitializer");
	}
	
	override void visit(const OrExpression orExpression)
	{
		mixin (tagAndAccept!"orExpression");
	}
	
	override void visit(const OrOrExpression orOrExpression)
	{
		mixin (tagAndAccept!"orOrExpression");
	}
	
	override void visit(const OutStatement outStatement)
	{
		mixin (tagAndAccept!"outStatement");
	}
	
	override void visit(const Parameter param)
	{
		output.writeln("<parameter>");
		if (param.name.type == tok!"identifier")
			output.writeln("<name>", param.name.text, "</name>");
		foreach (attribute; param.parameterAttributes)
		{
			output.writeln("<parameterAttribute>", str(attribute), "</parameterAttribute>");
		}
		param.accept(this);
		if (param.vararg)
			output.writeln("<vararg/>");
		output.writeln("</parameter>");
	}
	
	override void visit(const Parameters parameters)
	{
		mixin (tagAndAccept!"parameters");
	}
	
	override void visit(const Postblit postblit)
	{
		mixin (tagAndAccept!"postblit");
	}
	
	override void visit(const PostIncDecExpression postIncDecExpression)
	{
		output.writeln("<postIncDecExpression operator=\"",
		               str(postIncDecExpression.operator), "\">");
		postIncDecExpression.accept(this);
		output.writeln("</postIncDecExpression>");
	}
	
	override void visit(const PowExpression powExpression)
	{
		output.writeln("<powExpression>");
		output.writeln("<left>");
		powExpression.left.accept(this);
		output.writeln("</left>");
		if (powExpression.right !is null)
		{
			output.writeln("<right>");
			powExpression.right.accept(this);
			output.writeln("</right>");
		}
		output.writeln("</powExpression>");
	}
	
	override void visit(const PragmaDeclaration pragmaDeclaration)
	{
		mixin (tagAndAccept!"pragmaDeclaration");
	}
	
	override void visit(const PragmaExpression pragmaExpression)
	{
		mixin (tagAndAccept!"pragmaExpression");
	}
	
	override void visit(const PreIncDecExpression preIncDecExpression)
	{
		output.writeln("<preIncDecExpression operator=\"",
		               str(preIncDecExpression.operator), "\">");
		preIncDecExpression.accept(this);
		output.writeln("</preIncDecExpression>");
	}
	
	override void visit(const PrimaryExpression primaryExpression)
	{
		mixin (tagAndAccept!"primaryExpression");
	}
	
	// TODO: Register
	
	override void visit(const RelExpression relExpression)
	{
		output.writeln("<relExpression operator=\"",
		               xmlEscape(str(relExpression.operator)), "\">");
		output.writeln("<left>");
		relExpression.left.accept(this);
		output.writeln("</left>");
		output.writeln("<right>");
		relExpression.right.accept(this);
		output.writeln("</right>");
		output.writeln("</relExpression>");
	}
	
	override void visit(const ReturnStatement returnStatement)
	{
		if (returnStatement.expression is null)
			output.writeln("<returnStatement/>");
		else
		{
			output.writeln("<returnStatement>");
			returnStatement.accept(this);
			output.writeln("</returnStatement>");
		}
	}
	
	override void visit(const ScopeGuardStatement scopeGuardStatement)
	{
		mixin (tagAndAccept!"scopeGuardStatement");
	}
	
	override void visit(const SharedStaticConstructor sharedStaticConstructor)
	{
		mixin (tagAndAccept!"sharedStaticConstructor");
	}
	
	override void visit(const SharedStaticDestructor sharedStaticDestructor)
	{
		mixin (tagAndAccept!"sharedStaticDestructor");
	}
	
	override void visit(const ShiftExpression shiftExpression)
	{
		output.writeln("<shiftExpression operator=\"",
		               xmlEscape(str(shiftExpression.operator)), "\">");
		output.writeln("<left>");
		shiftExpression.left.accept(this);
		output.writeln("</left>");
		output.writeln("<right>");
		shiftExpression.right.accept(this);
		output.writeln("</right>");
		output.writeln("</shiftExpression>");
	}
	
	override void visit(const SingleImport singleImport)
	{
		if (singleImport.rename.type == tok!"")
			output.writeln("<singleImport>");
		else
			output.writeln("<singleImport rename=\"", singleImport.rename.text, "\">");
		visit(singleImport.identifierChain);
		output.writeln("</singleImport>");
	}
	
	override void visit(const SliceExpression sliceExpression)
	{
		output.writeln("<sliceExpression>");
		visit(sliceExpression.unaryExpression);
		if (sliceExpression.lower !is null)
		{
			output.writeln("<low>");
			visit(sliceExpression.lower);
			output.writeln("</low>");
		}
		if (sliceExpression.upper !is null)
		{
			output.writeln("<high>");
			visit(sliceExpression.upper);
			output.writeln("</high>");
		}
		output.writeln("</sliceExpression>");
	}
	
	override void visit(const Statement statement)
	{
		mixin (tagAndAccept!"statement");
	}
	
	override void visit(const StaticAssertDeclaration staticAssertDeclaration)
	{
		mixin (tagAndAccept!"staticAssertDeclaration");
	}
	
	override void visit(const StaticAssertStatement staticAssertStatement)
	{
		mixin (tagAndAccept!"staticAssertStatement");
	}
	
	override void visit(const StaticConstructor staticConstructor)
	{
		mixin (tagAndAccept!"staticConstructor");
	}
	
	override void visit(const StaticDestructor staticDestructor)
	{
		mixin (tagAndAccept!"staticDestructor");
	}
	
	override void visit(const StaticIfCondition staticIfCondition)
	{
		mixin (tagAndAccept!"staticIfCondition");
	}
	
	override void visit(const StorageClass storageClass)
	{
		mixin (tagAndAccept!"storageClass");
	}
	
	override void visit(const StructBody structBody)
	{
		mixin (tagAndAccept!"structBody");
	}
	
	override void visit(const StructDeclaration structDec)
	{
		output.writeln("<structDeclaration line=\"", structDec.name.line, "\">");
		output.writeln("<name>", structDec.name.text, "</name>");
		writeDdoc(structDec.comment);
		structDec.accept(this);
		output.writeln("</structDeclaration>");
	}
	
	override void visit(const StructInitializer structInitializer)
	{
		mixin (tagAndAccept!"structInitializer");
	}
	
	override void visit(const StructMemberInitializer structMemberInitializer)
	{
		mixin (tagAndAccept!"structMemberInitializer");
	}
	
	override void visit(const StructMemberInitializers structMemberInitializers)
	{
		mixin (tagAndAccept!"structMemberInitializers");
	}
	
	override void visit(const SwitchStatement switchStatement)
	{
		mixin (tagAndAccept!"switchStatement");
	}
	
	override void visit(const Symbol symbol)
	{
		mixin (tagAndAccept!"symbol");
	}
	
	override void visit(const SynchronizedStatement synchronizedStatement)
	{
		mixin (tagAndAccept!"synchronizedStatement");
	}
	
	override void visit(const TemplateAliasParameter templateAliasParameter)
	{
		output.writeln("<templateAliasParameter>");
		if (templateAliasParameter.type !is null)
			visit(templateAliasParameter.type);
		visit(templateAliasParameter.identifier);
		if (templateAliasParameter.colonExpression !is null)
		{
			output.writeln("<specialization>");
			visit(templateAliasParameter.colonExpression);
			output.writeln("</specialization>");
		}
		else if (templateAliasParameter.colonType !is null)
		{
			output.writeln("<specialization>");
			visit(templateAliasParameter.colonType);
			output.writeln("</specialization>");
		}
		
		if (templateAliasParameter.assignExpression !is null)
		{
			output.writeln("<default>");
			visit(templateAliasParameter.assignExpression);
			output.writeln("</default>");
		}
		else if (templateAliasParameter.assignType !is null)
		{
			output.writeln("<default>");
			visit(templateAliasParameter.assignType);
			output.writeln("</default>");
		}
		
		output.writeln("</templateAliasParameter>");
	}
	
	override void visit(const TemplateArgument templateArgument)
	{
		mixin (tagAndAccept!"templateArgument");
	}
	
	override void visit(const TemplateArgumentList templateArgumentList)
	{
		mixin (tagAndAccept!"templateArgumentList");
	}
	
	override void visit(const TemplateArguments templateArguments)
	{
		mixin (tagAndAccept!"templateArguments");
	}
	
	override void visit (const EponymousTemplateDeclaration eponymousTemplateDeclaration)
	{
		mixin (tagAndAccept!"eponymousTemplateDeclaration");
	}
	
	override void visit(const TemplateDeclaration templateDeclaration)
	{
		if (templateDeclaration.eponymousTemplateDeclaration !is null)
		{
			output.writeln("<templateDeclaration>");
			visit(templateDeclaration.eponymousTemplateDeclaration);
			output.writeln("</templateDeclaration>");
			return;
		}
		writeDdoc(templateDeclaration.comment);
		output.writeln("<templateDeclaration line=\"",
		               templateDeclaration.name.line, "\">");
		output.writeln("<name>", templateDeclaration.name.text, "</name>");
		visit(templateDeclaration.templateParameters);
		if (templateDeclaration.constraint !is null)
			visit(templateDeclaration.constraint);
		foreach (dec; templateDeclaration.declarations)
		{
			if (dec !is null) visit(dec);
		}
		output.writeln("</templateDeclaration>");
	}
	
	override void visit(const TemplateInstance templateInstance)
	{
		mixin (tagAndAccept!"templateInstance");
	}
	
	override void visit(const TemplateMixinExpression templateMixinExpression)
	{
		mixin (tagAndAccept!"templateMixinExpression");
	}
	
	override void visit(const TemplateParameter templateParameter)
	{
		mixin (tagAndAccept!"templateParameter");
	}
	
	override void visit(const TemplateParameterList templateParameterList)
	{
		mixin (tagAndAccept!"templateParameterList");
	}
	
	override void visit(const TemplateParameters templateParameters)
	{
		mixin (tagAndAccept!"templateParameters");
	}
	
	override void visit(const TemplateSingleArgument templateSingleArgument)
	{
		mixin (tagAndAccept!"templateSingleArgument");
	}
	
	override void visit(const TemplateThisParameter templateThisParameter)
	{
		mixin (tagAndAccept!"templateThisParameter");
	}
	
	override void visit(const TemplateTupleParameter templateTupleParameter)
	{
		mixin (tagAndAccept!"templateTupleParameter");
	}
	
	override void visit(const TemplateTypeParameter templateTypeParameter)
	{
		mixin (tagAndAccept!"templateTypeParameter");
	}
	
	override void visit(const TemplateValueParameter templateValueParameter)
	{
		mixin (tagAndAccept!"templateValueParameter");
	}
	
	override void visit(const TemplateValueParameterDefault templateValueParameterDefault)
	{
		mixin (tagAndAccept!"templateValueParameterDefault");
	}
	
	override void visit(const TernaryExpression ternaryExpression)
	{
		mixin (tagAndAccept!"ternaryExpression");
	}
	
	override void visit(const ThrowStatement throwStatement)
	{
		mixin (tagAndAccept!"throwStatement");
	}
	
	override void visit(const Token token)
	{
		string tagName;
		switch (token.type)
		{
			case tok!"": return;
			case tok!"identifier": tagName = "identifier"; break;
			case tok!"doubleLiteral": tagName = "doubleLiteral"; break;
			case tok!"idoubleLiteral": tagName = "idoubleLiteral"; break;
			case tok!"floatLiteral": tagName = "floatLiteral"; break;
			case tok!"ifloatLiteral": tagName = "ifloatLiteral"; break;
			case tok!"intLiteral": tagName = "intLiteral"; break;
			case tok!"uintLiteral": tagName = "uintLiteral"; break;
			case tok!"longLiteral": tagName = "longLiteral"; break;
			case tok!"ulongLiteral": tagName = "ulongLiteral"; break;
			case tok!"realLiteral": tagName = "realLiteral"; break;
			case tok!"irealLiteral": tagName = "irealLiteral"; break;
			case tok!"characterLiteral": tagName = "characterLiteral"; break;
			case tok!"stringLiteral": tagName = "stringLiteral"; break;
			case tok!"dstringLiteral": tagName = "dstringLiteral"; break;
			case tok!"wstringLiteral": tagName = "wstringLiteral"; break;
			case tok!"$": output.writeln("<dollar/>"); return;
			default: output.writeln("<", str(token.type), "/>"); return;
		}
		output.writeln("<", tagName, ">", xmlEscape(token.text), "</", tagName, ">");
	}
	
	override void visit(const TraitsExpression traitsExpression)
	{
		mixin (tagAndAccept!"traitsExpression");
	}
	
	override void visit(const TryStatement tryStatement)
	{
		mixin (tagAndAccept!"tryStatement");
	}

	override void visit(const Type type)
	{
		output.writeln("<type pretty=\"", "\">");
		type.accept(this);
		output.writeln("</type>");
	}
	
	override void visit(const Type2 type2)
	{
		if (type2.builtinType != tok!"")
			output.writeln("<type2>", str(type2.builtinType), "</type2>");
		else
		{
			output.writeln("<type2>");
			type2.accept(this);
			output.writeln("</type2>");
		}
	}
	
	override void visit(const TypeSpecialization typeSpecialization)
	{
		mixin (tagAndAccept!"typeSpecialization");
	}
	
	override void visit(const TypeSuffix typeSuffix)
	{
		if (typeSuffix.star)
			output.writeln("<typeSuffix type=\"*\"/>");
		else if (typeSuffix.array)
		{
			if (typeSuffix.low is null && typeSuffix.type is null)
				output.writeln("<typeSuffix type=\"[]\"/>");
			else
			{
				if (typeSuffix.low is null)
				{
					output.writeln("<typeSuffix type=\"[]\">");
					visit(typeSuffix.type);
					output.writeln("</typeSuffix>");
				}
				else
				{
					output.writeln("<typeSuffix type=\"[]\">");
					if (typeSuffix.high !is null)
					{
						output.writeln("<low>");
						visit(typeSuffix.low);
						output.writeln("</low>");
						output.writeln("<high>");
						visit(typeSuffix.high);
						output.writeln("</high>");
					}
					else
						visit(typeSuffix.low);
					output.writeln("</typeSuffix>");
				}
			}
		}
		else
		{
			visit(typeSuffix.delegateOrFunction);
			visit(typeSuffix.parameters);
			foreach (attr; typeSuffix.memberFunctionAttributes)
			{
				if (attr !is null) visit(attr);
			}
		}
	}
	
	override void visit(const TypeidExpression typeidExpression)
	{
		mixin (tagAndAccept!"typeidExpression");
	}
	
	override void visit(const TypeofExpression typeofExpression)
	{
		mixin (tagAndAccept!"typeofExpression");
	}
	
	override void visit(const UnaryExpression unaryExpression)
	{
		output.writeln("<unaryExpression>");
		if (unaryExpression.prefix != tok!"")
		{
			output.writeln("<prefix>", xmlEscape(unaryExpression.prefix.text),
			               "</prefix>");
			unaryExpression.unaryExpression.accept(this);
		}
		if (unaryExpression.suffix != tok!"")
		{
			unaryExpression.unaryExpression.accept(this);
			output.writeln("<suffix>", unaryExpression.suffix.text,
			               "</suffix>");
		}
		else
			unaryExpression.accept(this);
		output.writeln("</unaryExpression>");
	}
	
	override void visit(const UnionDeclaration unionDeclaration)
	{
		output.writeln("<unionDeclaration line=\"", unionDeclaration.name.line, "\">");
		if (unionDeclaration.name != tok!"")
			output.writeln("<name>", unionDeclaration.name.text, "</name>");
		if (unionDeclaration.templateParameters !is null)
			visit(unionDeclaration.templateParameters);
		if (unionDeclaration.constraint !is null)
			visit(unionDeclaration.constraint);
		if (unionDeclaration.structBody !is null)
			visit(unionDeclaration.structBody);
		output.writeln("</unionDeclaration>");
	}
	
	override void visit(const Unittest unittest_)
	{
		output.writeln("<unittest>");
		unittest_.accept(this);
		output.writeln("</unittest>");
	}
	
	override void visit(const VariableDeclaration variableDeclaration)
	{
		output.writeln("<variableDeclaration>");
		writeDdoc(variableDeclaration.comment);
		variableDeclaration.accept(this);
		output.writeln("</variableDeclaration>");
	}
	
	override void visit(const Vector vector)
	{
		mixin (tagAndAccept!"vector");
	}
	
	override void visit(const VersionCondition versionCondition)
	{
		mixin (tagAndAccept!"versionCondition");
	}
	
	override void visit(const VersionSpecification versionSpecification)
	{
		mixin (tagAndAccept!"versionSpecification");
	}
	
	override void visit(const WhileStatement whileStatement)
	{
		mixin (tagAndAccept!"whileStatement");
	}
	
	override void visit(const WithStatement withStatement)
	{
		mixin (tagAndAccept!"withStatement");
	}
	
	override void visit(const XorExpression xorExpression)
	{
		output.writeln("<xorExpression>");
		output.writeln("<left>");
		xorExpression.left.accept(this);
		output.writeln("</left>");
		if (xorExpression.right !is null)
		{
			output.writeln("<right>");
			xorExpression.right.accept(this);
			output.writeln("</right>");
		}
		output.writeln("</xorExpression>");
	}
	
	alias visit = ASTVisitor.visit;
	
	private static string xmlEscape(string s)
	{
		return s.translate(['<' : "&lt;", '>' : "&gt;", '&' : "&amp;"]);
	}
	
	private void writeDdoc(string comment)
	{
		if (comment is null) return;
		output.writeln("<ddoc>", xmlEscape(comment), "</ddoc>");
	}
	
	File output;
}


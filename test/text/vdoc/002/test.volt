module test;

import watt.text.sink;
import vdoc = watt.text.vdoc;

struct Section
{
	enum Type
	{
		Start,
		Content,
		End,
		P,
		Link,
		BriefStart,
		BriefContent,
		BriefEnd,
		ParamStart,
		ParamContent,
		ParamEnd,
	}

	type: Type;
	val: string;
}

fn typeToString(type: Section.Type) string
{
	final switch(type) with (Section.Type) {
	case Start: return "Start";
	case Content: return "Content";
	case End: return "End";
	case P: return "P";
	case Link: return "Link";
	case BriefStart: return "BriefStart";
	case BriefContent: return "BriefContent";
	case BriefEnd: return "BriefEnd";
	case ParamStart: return "ParamStart";
	case ParamContent: return "ParamContent";
	case ParamEnd: return "ParamEnd";
	}
}

class DocTester : vdoc.DocSink
{
public:
	fn test(src: string, expectedSequence: Section[])
	{
		mSequence = expectedSequence;
		vdoc.parse(src, this, null);
		assert(mSequence.length == 0);
	}

	override fn briefStart(sink: Sink)
	{
		check(Section.Type.BriefStart, "");
	}

	override fn briefEnd(sink: Sink)
	{
		check(Section.Type.BriefEnd, "");
	}

	override fn paramStart(sink: Sink, direction: string, arg: string)
	{
		check(Section.Type.ParamStart, direction ~ arg);
	}

	override fn paramEnd(sink: Sink)
	{
		check(Section.Type.ParamEnd, "");
	}

	override fn start(sink: Sink)
	{
		check(Section.Type.Start, "");
	}

	override fn end(sink: Sink)
	{
		check(Section.Type.End, "");
	}

	override fn content(sink: Sink, state: vdoc.DocState, d: string)
	{
		final switch (state) with (vdoc.DocState) {
		case Content: check(.Section.Type.Content, d); break;
		case Brief: check(.Section.Type.BriefContent, d); break;
		case Param: check(.Section.Type.ParamContent, d); break;
		case Section: break; // TODO
		}
	}

	override fn p(sink: Sink, state: vdoc.DocState, d: string)
	{
		check(Section.Type.P, d);
	}

	override fn link(sink: Sink, state: vdoc.DocState, target: string, text: string)
	{
		check(Section.Type.Link, target);
	}

	override fn defgroup(sink: Sink, group: string, text: string) { }
	override fn ingroup(sink: Sink, group: string) { }
	override fn sectionStart(sink: Sink, sec: vdoc.DocSection) { }
	override fn sectionEnd(sink: Sink, sec: vdoc.DocSection) { }


private:
	mSequence: Section[];


private:
	fn check(type: Section.Type, val: string)
	{
		assert(mSequence.length > 0);
		section := mSequence[0];
		mSequence = mSequence[1 .. $];
		assert(section.type == type);
		assert(section.val == val);
	}
}

fn main() i32
{
	tester := new DocTester();

	sequence0 := new Section[](3);
	sequence0[0].type = Section.Type.Start;
	sequence0[1].type = Section.Type.Content;
	sequence0[1].val  = "hello world";
	sequence0[2].type = Section.Type.End;
	tester.test("hello world", sequence0);

	sequence1 := new Section[](5);
	sequence1[0].type = Section.Type.Start;
	sequence1[1].type = Section.Type.Content;
	sequence1[1].val  = "hello ";
	sequence1[2].type = Section.Type.P;
	sequence1[2].val  = "x";
	sequence1[3].type = Section.Type.Content;
	sequence1[3].val  = " world";
	sequence1[4].type = Section.Type.End;
	tester.test("hello @p x world", sequence1);

	sequence2 := new Section[](5);
	sequence2[0].type = Section.Type.Start;
	sequence2[1].type = Section.Type.Content;
	sequence2[1].val  = "hello";
	sequence2[2].type = Section.Type.Link;
	sequence2[2].val  = "a.link";
	sequence2[3].type = Section.Type.Content;
	sequence2[3].val  = " world";
	sequence2[4].type = Section.Type.End;
	tester.test("hello@link a.link@endlink world", sequence2);

	sequence3 := new Section[](7);
	sequence3[0].type = Section.Type.Start;
	sequence3[1].type = Section.Type.Content;
	sequence3[1].val  = "This is normal content.\n";
	sequence3[2].type = Section.Type.BriefStart;
	sequence3[3].type = Section.Type.BriefContent;
	sequence3[3].val  = "This is a brief.";
	sequence3[4].type = Section.Type.BriefEnd;
	sequence3[5].type = Section.Type.Content;
	sequence3[5].val  = "This is not.";
	sequence3[6].type = Section.Type.End;
	tester.test("This is normal content.\n@brief This is a brief.\n\nThis is not.", sequence3);

	sequence4 := new Section[](9);
	sequence4[0].type = Section.Type.Start;
	sequence4[1].type = Section.Type.Content;
	sequence4[1].val  = "This is normal content.\n";
	sequence4[2].type = Section.Type.BriefStart;
	sequence4[3].type = Section.Type.BriefContent;
	sequence4[3].val  = "This is ";
	sequence4[4].type = Section.Type.P;
	sequence4[4].val  = "a";
	sequence4[5].type = Section.Type.BriefContent;
	sequence4[5].val  = " brief.";
	sequence4[6].type = Section.Type.BriefEnd;
	sequence4[7].type = Section.Type.Content;
	sequence4[7].val  = "This is not.";
	sequence4[8].type = Section.Type.End;
	tester.test("This is normal content.\n@brief This is @p a brief.\n\nThis is not.", sequence4);

	sequence5 := new Section[](7);
	sequence5[0].type = Section.Type.Start;
	sequence5[1].type = Section.Type.ParamStart;
	sequence5[1].val  = "outfoo";
	sequence5[2].type = Section.Type.ParamContent;
	sequence5[2].val  = "This ";
	sequence5[3].type = Section.Type.P;
	sequence5[3].val  = "is";
	sequence5[4].type = Section.Type.ParamContent;
	sequence5[4].val  = " a description.";
	sequence5[5].type = Section.Type.ParamEnd;
	sequence5[6].type = Section.Type.End;
	tester.test("@param[out] foo This @p is a description.", sequence5);

	return 0;
}

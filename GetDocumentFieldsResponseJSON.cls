public class GetDocumentFieldsResponseJSON {

	public String value;
	public Boolean state;
	public String fieldorder;
	public String label;
	public String element_type;
	public Integer signer;

	
	public static List<GetDocumentFieldsResponseJSON> parse(String json) {
		return (List<GetDocumentFieldsResponseJSON>) System.JSON.deserialize(json, List<GetDocumentFieldsResponseJSON>.class);
	}
}